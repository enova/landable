module Landable
  module TrafficHelper
    def crawl_tracker
      @tracker if @tracker.is_a? Landable::Traffic::CrawlTracker
    end

    def noop_tracker
      @tracker if @tracker.is_a? Landable::Traffic::NoopTracker
    end

    def ping_tracker
      @tracker if @tracker.is_a? Landable::Traffic::PingTracker
    end

    def scan_tracker
      @tracker if @tracker.is_a? Landable::Traffic::ScanTracker
    end

    def scrape_tracker
      @tracker if @tracker.is_a? Landable::Traffic::ScrapeTracker
    end

    def user_tracker
      @tracker if @tracker.is_a? Landable::Traffic::UserTracker
    end

    def tracker
      @tracker
    end
  end
end
