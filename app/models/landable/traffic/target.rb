module Landable
  module Traffic
    class Target < ActiveRecord::Base
      self.table_name = 'traffic.targets'

      lookup_by :target, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
