module Landable
  module Traffic
    class Location < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.locations"

      lookup_for :country, class_name: Country
      lookup_for :region,  class_name: Region
      lookup_for :city,    class_name: City
    end
  end
end
