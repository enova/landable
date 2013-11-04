module Landable
  module Traffic
    class City < ActiveRecord::Base
      self.table_name = 'traffic.cities'

      lookup_by :city, cache: 50, find_or_create: true

      has_many :locations
    end
  end
end
