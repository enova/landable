require_dependency 'landable/theme'
require_dependency 'landable/page_revision'
require_dependency 'landable/category'
require_dependency 'landable/has_assets'
require_dependency 'landable/author'

module Landable
  class Page < ActiveRecord::Base
    include ActionView::Helpers::TagHelper
    include Landable::HasAssets
    include Landable::Engine.routes.url_helpers

    validates_presence_of   :path, :status_code
    validates_presence_of   :redirect_url, if: -> page { page.redirect? }

    self.table_name = 'landable.pages'

    validates_inclusion_of  :status_code, in: [200, 301, 302, 404]

    validates_uniqueness_of :path
    validates :path, exclusion: { in: Landable.configuration.reserved_paths, message: "%{value} is reserved!" }
    validate :forbid_changing_path, on: :update

    validate :body_strip_search
    validates :redirect_url, url: true, allow_blank: true

    belongs_to :theme,                class_name: 'Landable::Theme',        inverse_of: :pages
    belongs_to :published_revision,   class_name: 'Landable::PageRevision'
    belongs_to :category,             class_name: 'Landable::Category'
    belongs_to :updated_by_author,    class_name: 'Landable::Author'
    has_many   :revisions,            class_name: 'Landable::PageRevision'
    has_many   :screenshots,          class_name: 'Landable::Screenshot',   as: :screenshotable

    scope :imported, -> { where("imported_at IS NOT NULL") }
    scope :sitemappable, -> { where("COALESCE(meta_tags -> 'robots' NOT LIKE '%noindex%', TRUE)") 
                              .where(status_code: 200)}

    before_validation :downcase_path!

    before_save -> page {
      page.lock_version ||= 0
      page.is_publishable = true unless page.published_revision_id_changed?
    }

    class << self
      def missing
        new(status_code: 404)
      end

      def by_path(path)
        where(path: path).first || missing
      end

      def by_path!(path)
        where(path: path).first!
      end

      def with_fuzzy_path(path)
        select("*, similarity(path, #{Page.sanitize path}) _sml").
          where('path LIKE ?', "%#{path}%").
          order('_sml DESC, path ASC')
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
        xml = Builder::XmlMarkup.new( :indent => 2 )
        xml.instruct! :xml, encoding: "UTF-8"
        xml.urlset(xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9") do |xml|
          pages.each do |page|
            next if options[:exclude_categories].to_a.include? page.category.try(:name)
            xml.url do |p|
              p.loc "#{options[:protocol]}://#{options[:host]}#{page.path}"
              p.lastmod page.updated_at
              p.changefreq 'weekly'
              p.priority '1'
            end
          end

          if options[:sitemap_additional_paths].present?
            options[:sitemap_additional_paths].each do |page|
              xml.url do |p|
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

    def html?
      content_type == 'text/html'
    end

    def directory_after(prefix)
      remainder = path.gsub(/^#{prefix}\/?/, '')
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
      if name and not name.empty?
        name = name.gsub(/^\/?(.*)/, '/\1')
      end

      self[:path] = name
    end

    def publish!(options)
      transaction do
        published_revision.unpublish! if published_revision
        revision = revisions.create! options
        update_attributes!(published_revision: revision, is_publishable: false)
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
      errors[:path] = "can not be changed!" if self.path_changed?
    end

    def body_strip_search
      begin
        RenderService.call(self)
      rescue ::Liquid::Error => error
        errors[:body] = 'contains a Liquid syntax error'
      rescue StandardError => error
        errors[:body] = 'had a problem: ' + error.message
      end
    end
  end
end
