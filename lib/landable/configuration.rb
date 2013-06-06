module Landable
  class Configuration
    attr_accessor :authenticator
    attr_writer :api_namespace, :public_namespace

    def authenticator
      @authenticator || raise("No Landable authenticator configured.")
    end

    def api_namespace
      @api_namespace ||= '/landable'
    end

    def public_namespace
      @public_namespace ||= '/'
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
  end
end
