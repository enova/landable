module Landable
  module Traffic
    class Browser < ActiveRecord::Base
      include Landable::TableName

      lookup_by :browser, cache: 50, find_or_create: true

      has_many :user_agents
    end
  end
end
