module Landable
  module Tracking
    class Location < ActiveRecord::Base
      self.table_name = 'traffic.locations'

      lookup_for :country, class_name: Country
      lookup_for :region,  class_name: Region
      lookup_for :city,    class_name: City
    end
  end
end
