module Landable
  module Traffic
    class IpAddress < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.ip_addresses"

      lookup_by :ip_address, cache: 50, find_or_create: true

      has_many :visitors
    end
  end
end
