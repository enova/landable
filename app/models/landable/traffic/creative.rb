module Landable
  module Traffic
    class Creative < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.creatives"

      lookup_by :creative, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
