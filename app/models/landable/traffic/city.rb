module Landable
  module Traffic
    class City < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.cities"

      lookup_by :city, cache: 50, find_or_create: true

      has_many :locations
    end
  end
end
