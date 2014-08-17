module Landable
  module Traffic
    class Visit < ActiveRecord::Base
      include Landable::TableName
      self.record_timestamps = false

      belongs_to :attribution
      belongs_to :cookie
      belongs_to :owner
      belongs_to :visitor
      belongs_to :referer

      has_many   :page_views
    end
  end
end
