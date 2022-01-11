require 'builder'
require_dependency 'landable/theme'
require_dependency 'landable/page_revision'
require_dependency 'landable/category'
require_dependency 'landable/has_assets'
require_dependency 'landable/author'

module Landable
  class Page < ActiveRecord::Base
    include ActionView::Helpers::TagHelper
    include Landable::HasAssets
    include Landable::HasTemplates
    include Landable::Engine.routes.url_helpers
    include Landable::TableName
    include Landable::Librarian

    validates_presence_of :path, :status_code
    validates_presence_of :redirect_url, if: -> page { page.redirect? }

    validates_inclusion_of :status_code, in: [200, 301, 302, 410]

    validates_with PathValidator, fields: [:path]
    validates_uniqueness_of :path
    validates :path, presence: true

    validate :page_name_byte_size

    validate :forbid_changing_path, on: :update

    validate :body_strip_search
    validates :redirect_url, url: true, allow_blank: true
    validate :hero_asset_existence

    belongs_to :theme,                class_name: 'Landable::Theme', inverse_of: :pages, counter_cache: true
    belongs_to :published_revision,   class_name: 'Landable::PageRevision'
    belongs_to :category,             class_name: 'Landable::Category'
    belongs_to :updated_by_author,    class_name: 'Landable::Author'
    belongs_to :hero_asset,           class_name: 'Landable::Asset'
    has_many :revisions,            class_name: 'Landable::PageRevision'
    has_many :screenshots,          class_name: 'Landable::Screenshot',   as: :screenshotable
    has_many :audits,               class_name: 'Landable::Audit',        as: :auditable

    delegate :republish!, to: :published_revision

    scope :imported, -> { where('imported_at IS NOT NULL') }
    scope :sitemappable, lambda {
      where("COALESCE(meta_tags -> 'robots' NOT LIKE '%noindex%', TRUE)")
        .where('published_revision_id is NOT NULL')
        .where(status_code: 200)
    }
    scope :published, -> { where('published_revision_id is NOT NULL') }

    before_validation :downcase_path!

    before_save lambda  { |page|
      page.lock_version ||= 0
      page.is_publishable = true unless page.published_revision_id_changed?
    }

    class << self
      def missing
        new(status_code: 410)
      end

      def by_path(path)
        where(path: path).first || missing
      end

      def by_path!(path)
        where(path: path).first!
      end

      def with_fuzzy_path(path)
        select("*, similarity(path, #{Page.sanitize path}) _sml")
          .where('path LIKE ?', "%#{path}%")
          .order('_sml DESC, path ASC')
      end

      def example(attrs)
        defaults = {
          title: 'Example page',
          body:  '<div>Example page contents would live here</div>'
        }

        new defaults.merge(attrs)
      end

      def generate_sitemap(options = {})
        pages = Landable::Page.sitemappable
        xml = Builder::XmlMarkup.new(indent: 2)
        xml.instruct! :xml, encoding: 'UTF-8'
        xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do |markup|
          pages.each do |page|
            next if options[:exclude_categories].to_a.include? page.category.try(:name)
            markup.url do |p|
              p.loc "#{options[:protocol]}://#{options[:host]}#{page.path}"
              p.lastmod page.updated_at.to_time.iso8601
              p.changefreq 'weekly'
              p.priority '1'
            end
          end

          if options[:sitemap_additional_paths].present?
            options[:sitemap_additional_paths].each do |page|
              markup.url do |p|
                p.loc "#{options[:protocol]}://#{options[:host]}#{page}"
                p.changefreq 'weekly'
                p.priority '1'
              end
            end
          end
        end
      end
    end

    def downcase_path!
      path.try :downcase!
    end

    def path_extension
      path.match(/\.(\w{2,})$/).try(:[], 1) if path
    end

    def content_type
      case path_extension
      when nil, 'htm', 'html'
        'text/html'
      when 'json'
        'application/json'
      when 'xml'
        'application/xml'
      else
        'text/plain'
      end
    end

    def deactivate
      update_attribute(:status_code, 410)

      publish!(author_id: updated_by_author.id, notes: 'This page has been trashed')

      super
    end

    def html?
      content_type == 'text/html'
    end

    def directory_after(prefix)
      remainder = path.gsub(%r{^#{prefix}\/?}, '')
      segments  = remainder.split('/', 2)
      if segments.length == 1
        nil
      else
        segments.first
      end
    end

    def redirect?
      status_code == 301 || status_code == 302
    end

    def path=(name)
      # if not present, add a leading slash for a non-empty path
      name = name.gsub(%r{^\/?(.*)}, '/\1') if name && !name.empty?

      self[:path] = name
    end

    def hero_asset_name
      hero_asset.try(:name)
    end

    def hero_asset_name=(name)
      @hero_asset_name = name
      asset = Asset.find_by_name(name)
      self.hero_asset_id = asset.try(:asset_id)
    end

    def hero_asset_url
      hero_asset.try(:public_url)
    end

    def publish!(options)
      transaction do
        published_revision.unpublish! if published_revision
        revision = revisions.create! options
        update!(published_revision: revision, is_publishable: false)
      end
    end

    def published?
      published_revision.present?
    end

    def revert_to!(revision)
      self.title          = revision.title
      self.path           = revision.path
      self.body           = revision.body
      self.head_content   = revision.head_content
      self.category_id    = revision.category_id
      self.theme_id       = revision.theme_id
      self.status_code    = revision.status_code
      self.meta_tags      = revision.meta_tags
      self.redirect_url   = revision.redirect_url

      save!
    end

    def preview_path
      public_preview_page_path(self)
    end

    def preview_url
      public_preview_page_url(self)
    end

    def forbid_changing_path
      errors[:path] = 'can not be changed!' if self.path_changed?
    end

    def body_strip_search
      RenderService.call(self)
    rescue ::Liquid::Error
      errors[:body] = 'contains a Liquid syntax error'
    rescue StandardError => error
      errors[:body] = 'had a problem: ' + error.message
    end

    def page_name_byte_size
      return unless page_name.present? && page_name.bytesize > 100
      errors[:page_name] = 'Invalid PageName, bytesize is too big!'
    end

    def hero_asset_existence
      return true if @hero_asset_name.blank?
      return if Asset.find_by_name(@hero_asset_name)
      errors[:hero_asset_name] = "System can't find an asset with this name"
    end

    def to_liquid
      {
        'title' => title,
        'url' => path,
        'hero_asset' => hero_asset ? true : false,
        'hero_asset_url' => hero_asset_url,
        'abstract' => abstract
      }
    end

    module Errors
      extend ActiveSupport::Concern

      class GoneError < Error
        STATUS_CODE = 410
      end

      def error?
        (400..599).cover? status_code
      end

      def error
        return nil unless error?

        case status_code
        when 410
          GoneError.new
        else
          Landable::Error.new "Missing a Page error class for #{status_code}"
        end
      end
    end

    include Errors
  end
end
