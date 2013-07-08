require_dependency "landable/api_controller"

module Landable
  module Api
    class LayoutsController < ApiController
      def index
        respond_with Layout.all
      end
    end
  end
end
