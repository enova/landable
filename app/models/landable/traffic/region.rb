module Landable
  module Traffic
    class Region < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :region, cache: 50, find_or_create: true

      has_many :locations
    end
  end
end
