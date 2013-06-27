require_dependency 'landable/asset_attachment'

module Landable
  class PageAsset < ActiveRecord::Base
    self.table_name = 'landable.page_assets'
    include Landable::AssetAttachment
    belongs_to :page
  end
end
