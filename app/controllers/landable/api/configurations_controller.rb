require_dependency 'landable/api_controller'

module Landable
  module Api
    class ConfigurationsController < ApiController
      def show
        respond_with configurations: [Landable.configuration.as_json]
      end
    end
  end
end
