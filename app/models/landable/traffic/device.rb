module Landable
  module Traffic
    class Device < ActiveRecord::Base
      include Landable::TableName

      lookup_by :device, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
