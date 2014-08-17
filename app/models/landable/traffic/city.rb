module Landable
  module Traffic
    class City < ActiveRecord::Base
      include Landable::TableName

      lookup_by :city, cache: 50, find_or_create: true

      has_many :locations
    end
  end
end
