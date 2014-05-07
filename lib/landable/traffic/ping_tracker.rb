module Landable
  module Traffic
    class PingTracker < Tracker
      def save
        record_access
      end
    end
  end
end
