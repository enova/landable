require 'landable/tracking/tracker'
require 'landable/tracking/crawl_tracker'
require 'landable/tracking/ping_tracker'
require 'landable/tracking/scan_tracker'
require 'landable/tracking/scrape_tracker'
require 'landable/tracking/user_tracker'

module Landable
  module Tracking
    def track_with_landable!
      begin
        @tracker = Tracker.for self
        @tracker.track
      rescue => e
        Rails.logger.error e
      end

      yield

      begin
        @tracker.save
      rescue => e
        Rails.logger.error e
      end
    end
  end
end
