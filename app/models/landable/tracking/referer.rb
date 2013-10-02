module Landable
  module Tracking
    class Referer < ActiveRecord::Base
      self.table_name = 'traffic.referers'

      lookup_for :domain, class_name: Domain
      lookup_for :path,   class_name: Path
    end
  end
end
