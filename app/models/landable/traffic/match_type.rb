module Landable
  module Traffic
    class MatchType < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.match_types"

      lookup_by :match_type, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
