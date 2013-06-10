require_dependency "landable/application_controller"

module Landable
  module Api
    class ThemesController < ApiController
      def index
        render json: Theme.all, each_serializer: ThemeSerializer
      end

      def create
        theme = Theme.new(theme_params)
        theme.save!
        render json: theme, serializer: ThemeSerializer, status: :created, location: theme_url(theme)
      end

      def show
        theme = Theme.find(params[:id])
        render json: theme, serializer: ThemeSerializer
      end

      def update
        theme = Theme.find(params[:id])
        theme.update_attributes! theme_params
        render json: theme, serializer: ThemeSerializer
      end

      private

      def theme_params
        params.require(:theme).permit(:id, :name, :body, :description, :screenshot_url)
      end
    end
  end
end
