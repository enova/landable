module Landable
  module Tracking
    class Country < ActiveRecord::Base
      self.table_name = 'traffic.countries'

      lookup_by :country, cache: true, find_or_create: true

      has_many :locations
    end
  end
end
