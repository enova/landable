module Landable
  class PageRevisionAsset < ActiveRecord::Base
    self.table_name = 'landable.page_revision_assets'
    belongs_to :page_revision
    belongs_to :asset

    def alias=(value)
      value = value.blank? ? nil : value
      write_attribute(:alias, value)
    end
  end
end
