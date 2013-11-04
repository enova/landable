module Landable
  module Traffic
    class Region < ActiveRecord::Base
      self.table_name = 'traffic.regions'

      lookup_by :region, cache: 50, find_or_create: true

      has_many :locations
    end
  end
end
