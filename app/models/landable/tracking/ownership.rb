module Landable
  module Tracking
    class Ownership < ActiveRecord::Base
      self.table_name = 'traffic.ownerships'

      belongs_to :cookie

      lookup_for :owner, class_name: Owner
    end
  end
end
