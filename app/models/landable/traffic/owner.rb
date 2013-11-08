module Landable
  module Traffic
    class Owner < ActiveRecord::Base
      self.table_name = 'traffic.owners'

      has_many :ownerships
      has_many :visits
    end
  end
end
