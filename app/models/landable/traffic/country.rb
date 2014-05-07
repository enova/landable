module Landable
  module Traffic
    class Country < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :country, cache: true, find_or_create: true

      has_many :locations
    end
  end
end
