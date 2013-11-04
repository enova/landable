module Landable
  module Traffic
    class ScrapeTracker < Tracker
      def save
        record_access
      end
    end
  end
end
