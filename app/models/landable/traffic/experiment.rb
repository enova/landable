module Landable
  module Traffic
    class Experiment < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.experiments"

      lookup_by :experiment, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
