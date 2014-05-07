module Landable
  module Traffic
    class Location < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_for :country, class_name: Country
      lookup_for :region,  class_name: Region
      lookup_for :city,    class_name: City
    end
  end
end
