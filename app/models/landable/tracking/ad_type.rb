module Landable
  module Tracking
    class AdType < ActiveRecord::Base
      self.table_name = 'traffic.ad_types'

      lookup_by :ad_type, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
