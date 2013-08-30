require_dependency 'landable/theme'
require_dependency 'landable/page_revision'
require_dependency 'landable/category'
require_dependency 'landable/status_code'
require_dependency 'landable/has_assets'
require_dependency 'landable/head_tag'

module Landable
  class Page < ActiveRecord::Base
    include Landable::HasAssets
    include Landable::Engine.routes.url_helpers

    validates_presence_of   :path#, :status_code

    self.table_name = 'landable.pages'

    validates_uniqueness_of :path
    validates_presence_of   :redirect_url, if: -> page { page.redirect? }

    belongs_to :theme, class_name: 'Landable::Theme', inverse_of: :pages
    belongs_to :published_revision, class_name: 'Landable::PageRevision'
    belongs_to :category, class_name: 'Landable::Category'
    has_many   :revisions, class_name: 'Landable::PageRevision'
    has_many   :screenshots, class_name: 'Landable::Screenshot', as: :screenshotable
    has_many   :head_tags, class_name: 'Landable::HeadTag'
    belongs_to :status_code, class_name: 'Landable::StatusCode'

    accepts_nested_attributes_for :head_tags

    scope :imported, -> { where("imported_at IS NOT NULL") }

    before_validation :downcase_path

    after_initialize do |page|
      page.status_code = StatusCode.where(code: 200).first unless page.status_code
    end

    before_save -> page {
      page.is_publishable = true unless page.published_revision_id_changed?
    }

    class << self
      def missing
        new(status_code: StatusCode.where(code: 404).first)
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
    end

    def downcase_path
      path.try :downcase!
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
      status_code.is_redirect?
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
      update_attributes! revision.snapshot_attributes
    end

    def preview_url
      public_preview_page_url(self)
    end

    #helps create/delete head_tags, needed because of embers issues with hasMany relationships 
    alias :head_tags_attributes_original= :head_tags_attributes= 

    def head_tags_attributes=(attrs)
      attrs ||= []
      ids = attrs.map { |ht| ht['id'] }.reject(&:blank?)

      if ids.empty?
        head_tags.delete_all
      else
        head_tags.where('head_tag_id NOT IN (?)', ids).delete_all
      end

      self.head_tags_attributes_original = attrs
    end
  end
end
