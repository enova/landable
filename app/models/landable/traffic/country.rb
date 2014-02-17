module Landable
  module Traffic
    class Country < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.countries"

      lookup_by :country, cache: true, find_or_create: true

      has_many :locations
    end
  end
end
