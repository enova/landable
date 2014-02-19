module Landable
  module Traffic
    class Event < ActiveRecord::Base
      include Landable::Traffic::TableName
      self.record_timestamps = false

      lookup_for :event_type, class_name: EventType, symbolize: true

      belongs_to :visit
    end
  end
end
