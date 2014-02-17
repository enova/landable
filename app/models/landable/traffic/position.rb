module Landable
  module Traffic
    class Position < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.positions"

      lookup_by :position, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
