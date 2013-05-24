require_dependency "landable/application_controller"

module Landable
  module Api
    class ThemesController < ApiController
      def index
        render json: Landable.themes
      end
    end
  end
end
