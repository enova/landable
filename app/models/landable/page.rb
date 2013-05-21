module Landable
  class Page < ActiveRecord::Base
    self.table_name = 'landable.pages'

    validates_presence_of  :path, :status_code
    validates_inclusion_of :status_code, in: [200, 301, 302, 404]
    validates_presence_of  :redirect_url, if: -> page { page.redirect? }

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

    private

    def theme_exists
      return if theme.present?
      errors.add(:theme_name, "Unknown theme #{theme_name}")
    end
  end
end
