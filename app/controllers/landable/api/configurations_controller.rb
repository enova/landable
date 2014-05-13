require_dependency "landable/api_controller"

module Landable
  module Api
    class ConfigurationsController < ApiController
      def index
        respond_with configuration: Landable.configuration.as_json
      end
    end
  end
end
