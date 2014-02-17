module Landable
  module Traffic
    class Region < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.regions"

      lookup_by :region, cache: 50, find_or_create: true

      has_many :locations
    end
  end
end
