module Landable
  module Traffic
    class UserAgentType < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.user_agent_types"

      lookup_by :user_agent_type, cache: true

      has_many :user_agents
    end
  end
end
