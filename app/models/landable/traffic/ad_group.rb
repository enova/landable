module Landable
  module Traffic
    class AdGroup < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.ad_groups"

      lookup_by :ad_group, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
