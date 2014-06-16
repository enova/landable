require_dependency "landable/api_controller"

module Landable
  module Api
    class ConfigurationsController < ApiController
      skip_before_filter :require_author!

      def show
        respond_with configurations: [Landable.configuration.as_json]
      end
    end
  end
end
