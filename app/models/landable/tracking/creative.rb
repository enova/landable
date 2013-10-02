module Landable
  module Tracking
    class Creative < ActiveRecord::Base
      self.table_name = 'traffic.creatives'

      lookup_by :creative, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
