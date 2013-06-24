require_dependency 'landable/asset_attachment'

module Landable
  class PageRevisionAsset < ActiveRecord::Base
    self.table_name = 'landable.page_revision_assets'
    include Landable::AssetAttachment
    belongs_to :page_revision
  end
end
