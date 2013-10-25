module Landable
  module Tracking
    class Visit < ActiveRecord::Base
      self.table_name = 'traffic.visits'
      self.record_timestamps = false

      lookup_for :owner, class_name: Owner

      belongs_to :attribution
      belongs_to :cookie
      belongs_to :visitor

      has_many   :page_views
    end
  end
end
