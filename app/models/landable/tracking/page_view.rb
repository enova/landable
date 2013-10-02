module Landable
  module Tracking
    class PageView < ActiveRecord::Base
      self.table_name = 'traffic.page_views'

      belongs_to :visit

      lookup_for :path, class_name: Landable::Tracking::Path
    end
  end
end
