require_dependency "landable/application_controller"

module Landable
  module Api
    class ThemesController < ApplicationController
      def index
        render json: Landable.themes
      end
    end
  end
end
