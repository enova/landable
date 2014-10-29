require 'landable/traffic/tracker'
require 'landable/traffic/crawl_tracker'
require 'landable/traffic/ping_tracker'
require 'landable/traffic/scan_tracker'
require 'landable/traffic/scrape_tracker'
require 'landable/traffic/user_tracker'
require 'landable/traffic/noop_tracker'

module Landable
  module Traffic
    def track_with_landable!
      yield and return if (request.headers["DNT"] || untracked_path)
      begin
        @tracker = Tracker.for self
        @tracker.track
      rescue => e
        Rails.logger.error e
        if respond_to? :newrelic_notice_error
          newrelic_notice_error e
        end
      end

      yield

      begin
        @tracker.save
      rescue => e
        Rails.logger.error e
        if respond_to? :newrelic_notice_error
          newrelic_notice_error e
        end
      end
    end

    def untracked_path
      Landable.configuration.untracked_paths.include? request.fullpath
    end
  end
end
