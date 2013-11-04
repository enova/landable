module Landable
  module Traffic
    class Network < ActiveRecord::Base
      self.table_name = 'traffic.networks'

      lookup_by :network, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
