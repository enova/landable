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
        raise "Broke 1"
      rescue => e
        Rails.logger.error e
        if respond_to? :newrelic_notice_error
          Rails.logger.info "Rescued #1"
          newrelic_notice_error e
        end
      end

      yield

      begin
        @tracker.save
        raise "Broke 2"
      rescue => e
        Rails.logger.error e
        if respond_to? :newrelic_notice_error
          Rails.logger.info "Rescued #2"
          newrelic_notice_error e
        end
      end
    end
  end
end
