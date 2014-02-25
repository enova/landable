module Landable
  module Traffic
    class EventType < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :event_type, cache: true, find_or_create: true

      has_many :events
    end
  end
end
