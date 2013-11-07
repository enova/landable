module Landable
  module Traffic
    class Access < ActiveRecord::Base
      self.table_name = 'traffic.accesses'

      lookup_for :path, class_name: Path

      belongs_to :visitor
    end
  end
end