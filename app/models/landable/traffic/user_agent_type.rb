module Landable
  module Traffic
    class UserAgentType < ActiveRecord::Base
      include Landable::TableName

      lookup_by :user_agent_type, cache: true

      has_many :user_agents
    end
  end
end
