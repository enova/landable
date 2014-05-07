module Landable
  module Traffic
    class HTTPMethod < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :http_method, cache: true, find_or_create: true

      has_many :page_views
    end
  end
end
