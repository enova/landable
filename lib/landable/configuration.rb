module Landable
  class Configuration
    attr_writer :api_namespace, :public_namespace, :categories, :traffic_enabled
    attr_writer :sitemap_exclude_categories, :sitemap_protocol, :sitemap_host
    attr_writer :sitemap_additional_paths, :reserved_paths, :partials_to_templates, :database_schema_prefix

    def authenticators
      @authenticators || raise("No Landable authenticator configured.")
    end

    def authenticators=(authenticators)
      @authenticators = Array(authenticators)
    end

    alias :authenticator= :authenticators=

    def api_namespace
      @api_namespace ||= '/api/landable'
    end

    def public_namespace
      raise NotImplementedError
      @public_namespace ||= '/'
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

    class Screenshots
      attr_accessor :autorun
      attr_accessor :browserstack_username, :browserstack_password

      def initialize
        @autorun = true
      end
    end
  end
end
