require 'landable/traffic/tracker'
require 'landable/traffic/crawl_tracker'
require 'landable/traffic/ping_tracker'
require 'landable/traffic/scan_tracker'
require 'landable/traffic/scrape_tracker'
require 'landable/traffic/user_tracker'

module Landable
  module Traffic
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
