module Landable
  class Configuration
    attr_accessor :api_url, :public_url
    attr_writer :api_namespace, :public_namespace
    attr_writer :api_host, :public_host
    attr_writer :categories
    attr_writer :screenshots_enabled
    attr_writer :traffic_enabled
    attr_writer :sitemap_exclude_categories, :sitemap_protocol, :sitemap_host, :sitemap_additional_paths
    attr_writer :reserved_paths, :partials_to_templates, :database_schema_prefix
    attr_writer :publicist_url, :audit_flags
    attr_writer :blank_user_agent_string, :untracked_paths
    attr_writer :dnt_enabled

    def authenticators
      @authenticators || raise("No Landable authenticator configured.")
    end

    def authenticators=(authenticators)
      @authenticators = Array(authenticators)
    end

    alias :authenticator= :authenticators=

    def publicist_url
      @publicist_url ||= 'publicist.dev'
    end

    def api_uri
      if api_url.present?
        @api_uri ||= URI(api_url)
      end
    end

    def api_host
      @api_host ||= api_uri.try(:host)
    end

    def api_namespace
      @api_namespace ||= (api_uri.try(:path).presence || '/api/landable')
    end

    def public_uri
      if public_url.present?
        @public_uri ||= URI(public_url)
      end
    end

    def public_host
      @public_host ||= public_uri.try(:host)
    end

    def audit_flags
      @audit_flags ||= []
    end

    def public_namespace
      @public_namespace ||= (public_uri.try(:path).presence || '')
    end

    def database_schema_prefix
      @database_schema_prefix ||= ''
    end

    def database_schema_prefix=(val)
      @database_schema_prefix = "#{val}_" if val.present?
    end

    def categories
      # default categories
      @categories ||= {
        'Affiliates' => '',
        'PPC' => 'Pay-per-click',
        'SEO' => 'Search engine optimization',
        'Social' => '',
        'Email' => '',
        'Traditional' => '',
      }
    end

    def partials_to_templates
      @partials_to_templates ||= []
    end

    def reserved_paths
      @reserved_paths ||= []
    end

    def sitemap_exclude_categories
      @sitemap_exclude_categories ||= []
    end

    def sitemap_additional_paths
      @sitemap_additional_paths ||= []
    end

    def sitemap_protocol
      @sitemap_protocol ||= "http"
    end

    def sitemap_host
      @sitemap_host
    end

    def screenshots_enabled
      @screenshots_enabled ||= false
    end

    def traffic_enabled
      @traffic_enabled ||= false
    end

    def traffic_enabled=(val)
      raise ArgumentError.new("Landable::Configuration#traffic_enabled accepts false, true, :all or :html") unless [true, false, :all, :html].include? val
      @traffic_enabled = val
    end

    def cors
      @cors ||= CORS.new
    end

    def cors=(bool)
      raise ArgumentError.new("Landable::Configuration#cors should be assigned 'false' to disable CORS support") if bool != false
      cors.origins = []
    end

    class CORS
      def enabled?
        origins.any?
      end

      def origins
        @origins ||= []
      end

      def origins=(origins)
        @origins = Array(origins)
      end
    end

    def screenshots
      @screenshots ||= Screenshots.new
    end

    def blank_user_agent_string
      @blank_user_agent_string ||= 'blank'
    end

    def untracked_paths
      @untracked_paths ||= []
    end

    def dnt_enabled
      return true if @dnt_enabled.nil?

      @dnt_enabled
    end


    class Screenshots
      attr_accessor :autorun
      attr_accessor :browserstack_username, :browserstack_password

      def initialize
        @autorun = true
      end
    end
  end
end
