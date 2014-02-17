module Landable
  module Traffic
    class BidMatchType < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.bid_match_types"

      lookup_by :bid_match_type, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
