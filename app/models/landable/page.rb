module Landable
  class Page < ActiveRecord::Base
    self.table_name = 'landable.pages'

    validates_presence_of   :path, :status_code
    validates_uniqueness_of :path
    validates_inclusion_of  :status_code, in: [200, 301, 302, 404]
    validates_presence_of   :redirect_url, if: -> page { page.redirect? }

    belongs_to  :published_revision, class_name: 'PageRevision'
    has_many    :revisions, class_name: 'PageRevision'

    class << self
      def missing
        new(status_code: 404)
      end

      def by_path(path)
        where(path: path).first || missing
      end
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

    def theme
      return nil unless theme_name
      Landable.find_theme(theme_name)
    end

    def theme=(name)
      self.theme_name = name
    end

    def path=(name)
      # if not present, add a leading slash for a non-empty path
      if name and not name.empty?
        name = name.gsub(/^\/?(.*)/, '/\1')
      end

      self[:path] = name
    end

    def publish!(options)
      revision = revisions.create options
      self.published_revision = revision
      save!
   end

    private

    def theme_exists
      return if theme.present?
      errors.add(:theme_name, "Unknown theme #{theme_name}")
    end
  end
end
