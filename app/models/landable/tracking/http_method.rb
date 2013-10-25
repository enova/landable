module Landable
  module Tracking
    class HTTPMethod < ActiveRecord::Base
      self.table_name = 'traffic.http_methods'

      lookup_by :http_method, cache: true, find_or_create: true

      has_many :page_views
    end
  end
end
