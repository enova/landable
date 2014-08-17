module Landable
  module Traffic
    class Platform < ActiveRecord::Base
      include Landable::TableName

      lookup_by :platform, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
