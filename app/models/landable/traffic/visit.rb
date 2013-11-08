module Landable
  module Traffic
    class Visit < ActiveRecord::Base
      self.table_name = 'traffic.visits'
      self.record_timestamps = false

      belongs_to :attribution
      belongs_to :cookie
      belongs_to :owner
      belongs_to :visitor

      has_many   :page_views
    end
  end
end
