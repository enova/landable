module Landable
  class PageAsset < ActiveRecord::Base
    self.table_name = 'landable.page_assets'
    belongs_to :page
    belongs_to :asset

    def alias=(value)
      value = value.blank? ? nil : value
      write_attribute(:alias, value)
    end
  end
end
