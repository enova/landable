module Landable
  class Configuration
    attr_writer :api_namespace, :public_namespace
    attr_accessor :browsers

    def browsers
      table = CSV.read('config/browsers.csv', headers: true, header_converters: :symbol)
      @browsers ||= table.each_with_object([]) { |row, array| array << row.to_hash }
    end

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
