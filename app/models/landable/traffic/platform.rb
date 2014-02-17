module Landable
  module Traffic
    class Platform < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.platforms"

      lookup_by :platform, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
