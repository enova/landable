module Landable
  class ThemeAsset < ActiveRecord::Base
    self.table_name = 'landable.theme_assets'
    belongs_to :theme
    belongs_to :asset

    def alias=(value)
      value = value.blank? ? nil : value
      write_attribute(:alias, value)
    end
  end
end
