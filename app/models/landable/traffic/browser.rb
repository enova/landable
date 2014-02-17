module Landable
  module Traffic
    class Browser < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.browsers"

      lookup_by :browser, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
