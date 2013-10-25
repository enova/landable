module Landable
  module Tracking
    class UserAgentType < ActiveRecord::Base
      self.table_name = 'traffic.user_agent_types'

      lookup_by :user_agent_type, cache: true

      has_many :user_agents
    end
  end
end
