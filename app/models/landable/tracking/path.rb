module Landable
  module Tracking
    class Path < ActiveRecord::Base
      self.table_name = 'traffic.paths'

      lookup_by :path, cache: 50, find_or_create: true

      has_many :page_views
    end
  end
end
