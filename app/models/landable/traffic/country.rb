module Landable
  module Traffic
    class Country < ActiveRecord::Base
      include Landable::TableName

      lookup_by :country, cache: 50, find_or_create: true

      has_many :locations
    end
  end
end
