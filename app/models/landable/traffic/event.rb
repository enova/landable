module Landable
  module Traffic
    class Event < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.events"
      self.record_timestamps = false

      lookup_for :event_type, class_name: EventType, symbolize: true

      belongs_to :visit
    end
  end
end
