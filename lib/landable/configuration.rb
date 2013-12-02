module Landable
  class Configuration
    attr_writer :api_namespace, :public_namespace, :categories, :traffic_enabled
    attr_writer :sitemap_exclude_categories, :sitemap_protocol, :sitemap_host, :sitemap_additional_paths

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
