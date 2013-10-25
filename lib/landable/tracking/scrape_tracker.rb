module Landable
  module Tracking
    class ScrapeTracker < Tracker
      def save
        record_access
      end
    end
  end
end
