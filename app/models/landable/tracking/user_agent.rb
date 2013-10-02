module Landable
  module Tracking
    class UserAgent < ActiveRecord::Base
      self.table_name = 'traffic.user_agents'

      lookup_by  :user_agent, cache: 50, find_or_create: true

      lookup_for :user_agent_type, class_name: UserAgentType

      has_many :visitors

      after_initialize do
        self.user_agent_type = "user"
      end
    end
  end
end
