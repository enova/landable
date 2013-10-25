module Landable
  module Tracking
    class Platform < ActiveRecord::Base
      self.table_name = 'traffic.platforms'

      lookup_by :platform, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
