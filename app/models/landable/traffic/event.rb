module Landable
  module Traffic
    class Event < ActiveRecord::Base
      include Landable::TableName
      self.record_timestamps = false

      lookup_for :event_type, class_name: EventType

      belongs_to :visit
    end
  end
end
