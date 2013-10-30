module Landable
  module Traffic
    class ScanTracker < Tracker
      def save
        record_access
      end
    end
  end
end
