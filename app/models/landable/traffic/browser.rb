module Landable
  module Traffic
    class Browser < ActiveRecord::Base
      self.table_name = 'traffic.browsers'

      lookup_by :browser, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
