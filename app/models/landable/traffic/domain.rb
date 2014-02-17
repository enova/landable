module Landable
  module Traffic
    class Domain < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.domains"

      lookup_by :domain, cache: 50, find_or_create: true

      has_many :ip_lookups
      has_many :referers
    end
  end
end
