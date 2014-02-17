module Landable
  module Traffic
    class Device < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.devices"

      lookup_by :device, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
