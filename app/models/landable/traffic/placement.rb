module Landable
  module Traffic
    class Placement < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.placements"

      lookup_by :placement, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
