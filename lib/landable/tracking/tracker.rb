require 'digest/sha2'

module Landable
  module Tracking
    class Tracker
      QUERY_PARAMS = {
        "ad_type"        => %w[ad_type adtype],
        "bid_match_type" => %w[bidmatchtype bid_match_type bmt],
        "campaign"       => %w[campaign utm_campaign ovcampgid ysmcampgid],
        "content"        => %w[content utm_content],
        "creative"       => %w[creative],
        "device_type"    => %w[device_type devicetype],
        "keyword"        => %w[keyword kw utm_term ovkey ysmkey],
        "match_type"     => %w[match_type matchtype match ovmtc ysmmtc],
        "medium"         => %w[medium utm_medium],
        "network"        => %w[network],
        "placement"      => %w[placement],
        "position"       => %w[position adposition ad_position],
        "search_term"    => %w[search_term querystring ovraw ysmraw],
        "source"         => %w[source utm_source],
        "target"         => %w[target],
      }

      REFERER_PARAMS = {
        "search_term" => %w[q]
      }

      QUERY_PARAMS_TRANSFORM = {
        "ad_type"        => { 'pe'  => 'product_extensions',
                              'pla' => 'product_listing' },

        "bid_match_type" => { 'bb'  => 'bidded broad',
                              'bc'  => 'bidded content',
                              'be'  => 'bidded exact',
                              'bp'  => 'bidded phrase' },

        "device_type"    => { 'c'   => 'computer',
                              'm'   => 'mobile',
                              't'   => 'tablet' },

        "match_type"     => { 'b'   => 'broad',
                              'c'   => 'content',
                              'e'   => 'exact',
                              'p'   => 'phrase' },

        "network"        => { 'g'   => 'google_search',
                              's'   => 'search_partner',
                              'd'   => 'display_network' },
      }

      UUID_REGEX       = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\Z/
      UUID_REGEX_V4    = /\A\h{8}-\h{4}-4\h{3}-[89aAbB]\h{3}-\h{12}\Z/

      # Save space in the session by shortening names
      VISIT_ID         = 'vid'
      VISITOR_ID       = 'vsid'
      VISIT_TIME       = 'vt'
      VISITOR_HASH     = 'vh'
      ATTRIBUTION_HASH = 'ah'

      attr_reader :controller

      delegate :request, :session, to: :controller
      delegate :headers, :path, :query_parameters, :referer, :remote_ip, to: :request

      class << self
        def for(controller)
          "#{user_agent.user_agent_type.classify}Tracker".constantize.new(controller)
        end
      end

      def initialize(controller)
        # Allow subclasses to super from initialize
        raise NotImplementedError, "You must subclass Tracker" if self.class == Tracker

        @controller = controller
      end

      def track; raise NotImplementedError, "You must subclass Tracker"; end

      def visitor_id
        @visitor_id = visitor.id if visitor_changed?
        @visitor_id
      end

    protected
      def cookies
        request.cookie_jar
      end

      def cookie
        validate_cookie

        @cookie_id ||= Cookie.create.id

        set_cookie
      end

      def validate_cookie
        return unless @cookie_id
        return if @cookie_id =~ UUID_REGEX_V4 && Cookie.exists?(@cookie_id)

        # add_ip_to_graylist
        @cookie_id = nil
      end

      def set_cookie
        cookies.permanent[:landable] = cookie_defaults.merge(value: @cookie_id)
      end

      def cookie_defaults
        { domain: :all, secure: false, httponly: true }
      end

      def do_not_track
        return unless headers["DNT"]

        headers["DNT"] == "1"
      end

      def user_agent
        @user_agent ||= UserAgent[request.user_agent]
      end

      def ip_address
        @ip_address ||= IpAddress[remote_ip]
      end

      def attribution_hash
        Attribution.digest attribution_parameters
      end

      def visitor_hash
        Digest::SHA2.base64digest [remote_ip, request.user_agent].join
      end

      # TODO: Fix this
      def attribution?
        attribution_parameters.any?
      end

      def record_visit
        create_visit if new_visit?
      end

      def create_visit
        visit = Visit.new
        visit.attribution = attribution
        visit.cookie_id   = @cookie_id
        visit.visitor_id  = visitor_id
        visit.save!

        @visit_id = visit.id
      end

      def new_visit?
        @visit_id.nil? || attribution_changed? || visitor_changed? || visit_stale?
      end

      def visitor_changed?
        visitor_hash != @visitor_hash
      end

      def attribution_changed?
        attribution? && attribution_hash != @attribution_hash
      end

      def visit_stale?
        return false unless @last_visit_time

        Time.current - @last_visit_time > 30.minutes
      end

      def mapped_parameters
        return @mapped_parameters if @mapped_parameters

        hash = {}

        QUERY_PARAMS.each do |key, names|
          next unless name = names.find { |name| query_parameters.key?(name) }
          hash[key] = query_parameters[name]
        end

        QUERY_PARAMS_TRANSFORM.each do |k, transform|
          next unless hash.key? k

          hash[k] = transform[hash[k]] if transform.key? hash[k]
        end

        @mapped_parameters = hash
      end

      def attribution_parameters
        mapped_parameters
      end

      def attribution
        @attribution ||= Attribution.lookup attribution_parameters
      end

      def visitor
        @visitor ||= Visitor.with_ip_address(ip_address).with_user_agent(user_agent).first_or_create
      end
    end
  end
end
