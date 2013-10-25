module Landable
  module Tracking
    class PingTracker < Tracker
      def save
        record_access
      end
    end
  end
end
