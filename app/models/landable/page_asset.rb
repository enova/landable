module Landable
  class PageAsset < ActiveRecord::Base
    self.table_name = 'landable.page_assets'
    belongs_to :page
    belongs_to :asset
  end
end
