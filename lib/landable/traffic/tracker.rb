require 'digest/sha2'
require 'uri'

module Landable
  module Traffic
    class Tracker
      TRACKING_PARAMS = {
        "ad_type"        => %w[ad_type adtype],
        "ad_group"       => %w[ad_group adgroup ovadgrpid ysmadgrpid],
        "bid_match_type" => %w[bidmatchtype bid_match_type bmt],
        "campaign"       => %w[campaign utm_campaign ovcampgid ysmcampgid],
        "content"        => %w[content utm_content],
        "creative"       => %w[creative adid ovadid],
        "device_type"    => %w[device_type devicetype device],
        "click_id"       => %w[gclid click_id],
        "experiment"     => %w[experiment aceid],
        "keyword"        => %w[keyword kw utm_term ovkey ysmkey],
        "match_type"     => %w[match_type matchtype match ovmtc ysmmtc],
        "medium"         => %w[medium utm_medium],
        "network"        => %w[network],
        "placement"      => %w[placement],
        "position"       => %w[position adposition ad_position],
        "search_term"    => %w[search_term searchterm q querystring ovraw ysmraw],
        "source"         => %w[source utm_source],
        "target"         => %w[target],
      }.freeze

      TRACKING_KEYS    = TRACKING_PARAMS.values.flatten.freeze
      ATTRIBUTION_KEYS = TRACKING_PARAMS.except("click_id").keys

      TRACKING_PARAMS_TRANSFORM = {
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
                              'p'   => 'phrase',
                              'std' => 'standard',
                              'adv' => 'advanced',
                              'cnt' => 'content' },

        "network"        => { 'g'   => 'google_search',
                              's'   => 'search_partner',
                              'd'   => 'display_network' },
      }.freeze

      UUID_REGEX       = /\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\Z/
      UUID_REGEX_V4    = /\A\h{8}-\h{4}-4\h{3}-[89aAbB]\h{3}-\h{12}\Z/

      # Save space in the session by shortening names
      KEYS = {
        visit_id:         'vid',
        visitor_id:       'vsid',
        visit_time:       'vt',
        visitor_hash:     'vh',
        attribution_hash: 'ah',
        referer_hash:     'rh'
      }.freeze

      attr_reader :controller

      delegate :request, :response, :session, to: :controller
      delegate :headers, :path, :query_parameters, :referer, :remote_ip, to: :request

      class << self
        def for(controller)
          type = controller.request.user_agent.presence && Landable::Traffic::UserAgent[controller.request.user_agent].user_agent_type
          type = 'asset' if Landable.configuration.tracker_allowed_mimes and not Landable.configuration.tracker_allowed_mimes.any? { |mime| controller.request.format.to_s == mime}
          type = 'user'if type.nil?
          type = 'user'if controller.request.query_parameters.slice(*TRACKING_KEYS).any?

          "Landable::Traffic::#{type.classify}Tracker".constantize.new(controller)
        end
      end

      def initialize(controller)
        # Allow subclasses to super from initialize
        raise NotImplementedError, "You must subclass Tracker" if self.class == Tracker

        @controller = controller
      end

      def track
        raise NotImplementedError, "You must subclass Tracker" if self.class == Tracker
      end

      def visitor_id
        @visitor_id = visitor.id if visitor_changed?
        @visitor_id
      end

      def create_event(type, meta = {})
        return unless @visit_id

        Event.create(visit_id: @visit_id, event_type: type, meta: meta)
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
        return if @cookie_id =~ UUID_REGEX_V4 && Cookie[@cookie_id]

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

      def referer
        return @referer if @referer
        return unless referer_uri

        params      = Rack::Utils.parse_query referer_uri.query
        attribution = Attribution.lookup params.slice(*ATTRIBUTION_KEYS)
        query       = params.except(*ATTRIBUTION_KEYS)

        @referer = Referer.where(domain_id:       Domain[referer_uri.host],
                                 path_id:         Path[referer_uri.path],
                                 query_string_id: QueryString[query.to_query],
                                 attribution_id:  attribution.id).first_or_create
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

      def referer_hash
        Digest::SHA2.base64digest request.referer
      end

      def tracking?
        tracking_parameters.any?
      end

      def attribution?
        attribution_parameters.any?
      end

      def record_visit
        create_visit if new_visit?
      end

      def record_access
        access = Access.where(visitor_id: visitor_id, path_id: Path[request.path]).first_or_initialize
        access.last_accessed_at = Time.current
        access.save!
      end

      def create_visit
        visit = Visit.new
        visit.attribution  = attribution
        visit.cookie_id    = @cookie_id
        visit.referer_id   = referer.try(:id)
        visit.visitor_id   = visitor_id
        visit.do_not_track = do_not_track
        visit.save!

        @visit_id = visit.id
      end

      def new_visit?
        @visit_id.nil? || referer_changed? || attribution_changed? || visitor_changed? || visit_stale?
      end

      def referer_changed?
        external_referer? && referer_hash != @referer_hash
      end

      def referer_uri
        @referer_uri ||= URI(URI.encode(request.referer)) if request.referer
      end

      def external_referer?
        referer_uri && referer_uri.host != request.host
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

      def extract_tracking(params)
        hash = {}

        TRACKING_PARAMS.each do |key, names|
          next unless param = names.find { |name| params.key?(name) }
          hash[key] = params[param]
        end

        TRACKING_PARAMS_TRANSFORM.each do |key, transform|
          next unless hash.key? key

          hash[key] = transform[hash[key]] if transform.key? hash[key]
        end

        hash
      end

      def tracking_parameters
        @tracking_parameters ||= extract_tracking(query_parameters)
      end

      def untracked_parameters
        query_parameters.except(*TRACKING_PARAMS.values.flatten)
      end

      def attribution_parameters
        @attribution_parameters ||= tracking_parameters.slice(*ATTRIBUTION_KEYS)
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
