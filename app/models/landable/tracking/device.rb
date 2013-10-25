module Landable
  module Tracking
    class Device < ActiveRecord::Base
      self.table_name = 'traffic.devices'

      lookup_by :device, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
