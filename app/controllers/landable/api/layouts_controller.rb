require_dependency "landable/api_controller"

module Landable
  module Api
    class LayoutsController < ApiController
      def index
        respond_with Layout.all
      end

      def create
        layout = Layout.new(layout_params)
        layout.save!
        respond_with layout, status: :created, location: layout_url(layout)
      end

      def show
        respond_with Layout.find(params[:id])
      end

      def update
        layout = Layout.find(params[:id])
        layout.update_attributes! layout_params
        respond_with layout
      end

      private

      def layout_params
        params.require(:layout).permit(:id, :name, :body, :description, :screenshot_url)
      end
    end
  end
end
