module Landable
  module Traffic
    class HTTPMethod < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.http_methods"

      lookup_by :http_method, cache: true, find_or_create: true

      has_many :page_views
    end
  end
end
