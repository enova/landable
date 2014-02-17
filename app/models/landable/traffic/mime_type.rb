module Landable
  module Traffic
    class MimeType < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.mime_types"

      lookup_by :mime_type, cache: 50, find_or_create: true

      has_many :page_views
    end
  end
end
