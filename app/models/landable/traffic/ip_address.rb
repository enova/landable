module Landable
  module Traffic
    class IpAddress < ActiveRecord::Base
      include Landable::TableName

      lookup_by :ip_address, cache: 50, find_or_create: true

      has_many :visitors
    end
  end
end
