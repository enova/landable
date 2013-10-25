module Landable
  module Tracking
    class ScanTracker < Tracker
      def save
        record_access
      end
    end
  end
end
