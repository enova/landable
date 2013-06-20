require_dependency 'landable/theme'
require_dependency 'landable/page_revision'
require_dependency 'landable/category'

module Landable
  class Page < ActiveRecord::Base
    self.table_name = 'landable.pages'

    validates_presence_of   :path, :status_code
    validates_uniqueness_of :path
    validates_inclusion_of  :status_code, in: [200, 301, 302, 404]
    validates_presence_of   :redirect_url, if: -> page { page.redirect? }

    belongs_to :theme, class_name: 'Landable::Theme', inverse_of: :pages
    belongs_to :published_revision, class_name: 'Landable::PageRevision'
    belongs_to :category, class_name: 'Landable::Category'
    has_many   :revisions, class_name: 'Landable::PageRevision'

    has_many :page_assets
    has_many :assets, :through => :page_assets

    scope :imported, -> { where("imported_at IS NOT NULL") }

    before_validation :downcase_path

    before_save -> page {
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
      self.published_revision.unpublish! if self.published_revision
      revision = revisions.create options
      self.published_revision = revision
      self.is_publishable = false
      save!
    end

    def revert_to!(revision)
      self.published_revision.unpublish! if self.published_revision
      self.published_revision = revision
      self.published_revision.publish!
      self.attributes = revision.snapshot_attributes[:attrs]
      save!
    end
  end
end
