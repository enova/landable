module Landable
  class ThemeAsset < ActiveRecord::Base
    self.table_name = 'landable.theme_assets'
    belongs_to :theme
    belongs_to :asset
  end
end
