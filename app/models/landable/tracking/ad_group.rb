module Landable
  module Tracking
    class AdGroup < ActiveRecord::Base
      self.table_name = 'traffic.ad_groups'

      lookup_by :ad_group, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
