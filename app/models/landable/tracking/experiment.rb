module Landable
  module Tracking
    class Experiment < ActiveRecord::Base
      self.table_name = 'traffic.experiments'

      lookup_by :experiment, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
