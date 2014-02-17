module Landable
  module Traffic
    class Owner < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.owners"

      has_many :ownerships
      has_many :visits
    end
  end
end
