module Landable
  module Tracking
    class CrawlTracker < Tracker
      def save
        record_access
      end
    end
  end
end
