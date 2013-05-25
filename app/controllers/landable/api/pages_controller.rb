require_dependency "landable/application_controller"

module Landable
  module Api
    class PagesController < ApiController
      def create
        @page = Page.new page_params
        @page.save!
        render json: @page, serializer: Landable::PageSerializer, status: :created, location: url_for(@page)
      end

      def show
        @page = Page.find params[:id]
        render json: @page, serializer: Landable::PageSerializer
      end

      def update
        @page = Page.find params[:id]
        @page.update_attributes! page_params
        render json: @page, serializer: Landable::PageSerializer
      end

      def preview
        RenderService.call self, Page.find(params[:id])
      end

      private

      def page_params
        params.require(:page).permit(:id, :path, :theme_name, :title, :body, :status_code, :redirect_url)
      end
    end
  end
end
