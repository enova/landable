module Landable
  module Traffic
    class Campaign < ActiveRecord::Base
      self.table_name = 'traffic.campaigns'

      lookup_by :campaign, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
