module Landable
  module Traffic
    class EventType < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.event_types"

      lookup_by :event_type, cache: true, find_or_create: true

      has_many :events
    end
  end
end
