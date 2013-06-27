require_dependency 'landable/asset_attachment'

module Landable
  class ThemeAsset < ActiveRecord::Base
    self.table_name = 'landable.theme_assets'
    include Landable::AssetAttachment
    belongs_to :theme
  end
end
