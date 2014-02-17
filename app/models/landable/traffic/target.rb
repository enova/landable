module Landable
  module Traffic
    class Target < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.targets"

      lookup_by :target, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
