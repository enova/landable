module Landable
  module Traffic
    class Ownership < ActiveRecord::Base
      self.table_name = 'traffic.ownerships'

      belongs_to :cookie
      belongs_to :owner
    end
  end
end
