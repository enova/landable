module Landable
  module Tracking
    class EventType < ActiveRecord::Base
      self.table_name = 'traffic.event_types'

      lookup_by :event_type, cache: true, find_or_create: true

      has_many :events
    end
  end
end
