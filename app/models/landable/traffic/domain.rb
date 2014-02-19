module Landable
  module Traffic
    class Domain < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :domain, cache: 50, find_or_create: true

      has_many :ip_lookups
      has_many :referers
    end
  end
end
