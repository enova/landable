module Landable
  module Traffic
    class DeviceType < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.device_types"

      lookup_by :device_type, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
