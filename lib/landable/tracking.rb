require 'landable/tracking/tracker'
require 'landable/tracking/user_tracker'

module Landable
  module Tracking
    def track_with_landable!
      # @tracker ||= Tracker.for self
      @tracker ||= UserTracker.new(self)

      @tracker.track

      yield

      # set current_visit
    end
  end
end
