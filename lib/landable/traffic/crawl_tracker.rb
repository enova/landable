module Landable
  module Traffic
    class CrawlTracker < Tracker
      def save
        record_access
      end
    end
  end
end
