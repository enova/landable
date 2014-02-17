module Landable
  module Traffic
    class Ownership < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.ownerships"

      belongs_to :cookie
      belongs_to :owner
    end
  end
end
