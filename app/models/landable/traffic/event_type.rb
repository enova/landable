module Landable
  module Traffic
    class EventType < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :event_type, cache: 50, find_or_create: true

      has_many :events
    end
  end
end
