module Landable
  module Traffic
    class NoopTracker < Tracker
      def save
      end
    end
  end
end
