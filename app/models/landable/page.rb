module Landable
  class Page < ActiveRecord::Base
    self.table_name = 'landable.pages'

    validates_presence_of :theme_name, :title, :body

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
