module Landable
  module Tracking
    class Position < ActiveRecord::Base
      self.table_name = 'traffic.positions'

      lookup_by :position, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
