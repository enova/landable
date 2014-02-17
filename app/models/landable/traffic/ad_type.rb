module Landable
  module Traffic
    class AdType < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.ad_types"

      lookup_by :ad_type, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
