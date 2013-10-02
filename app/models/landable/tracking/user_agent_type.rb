module Landable
  module Tracking
    class UserAgentType < ActiveRecord::Base
      self.table_name = 'traffic.user_agent_types'

      lookup_by :user_agent_type
    end
  end
end
