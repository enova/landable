module Landable
  module Traffic
    class UserAgentType < ActiveRecord::Base
      include Landable::TableName

      lookup_by :user_agent_type, cache: 5, find_or_create: true

      has_many :user_agents
    end
  end
end
