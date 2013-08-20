require_dependency "landable/api_controller"

module Landable
  module Api
    class BrowsersController < ApiController

      def index
        respond_with Landable::Browser.all
      end

      def show
        respond_with Landable::Browser.find(params[:id])
      end

    end
  end
end
