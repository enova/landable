module Landable
  module Traffic
    class Source < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.sources"

      lookup_by :source, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
