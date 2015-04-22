require 'landable/traffic/tracker'
require 'landable/traffic/crawl_tracker'
require 'landable/traffic/ping_tracker'
require 'landable/traffic/scan_tracker'
require 'landable/traffic/scrape_tracker'
require 'landable/traffic/user_tracker'
require 'landable/traffic/noop_tracker'
require 'landable/traffic/event_publisher'

module Landable
  module Traffic
    def track_with_landable!
      yield and return if untracked?

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

    def untracked?
      untracked_user? || untracked_path?
    end

    def untracked_user?
      Landable.configuration.dnt_enabled && request.headers["DNT"] == "1"
    end

    def untracked_path?
      Landable.configuration.untracked_paths.include? request.fullpath
    end
  end
end
