module Landable
  module Tracking
    class Domain < ActiveRecord::Base
      self.table_name = 'traffic.domains'

      lookup_by :domain
    end
  end
end
