require_dependency "landable/api_controller"

module Landable
  module Api
    class PagesController < ApiController
      def index
        ids = params[:ids] if params[:ids].present? and params[:ids].is_a? Array

        if ids
          pages = Page.where(page_id: params[:ids])
        else
          pages = Page.all
        end

        render json: pages
      end

      def create
        @page = Page.new page_params
        @page.save!
        render json: @page, serializer: Landable::PageSerializer, status: :created, location: page_url(@page)
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
        respond_to do |format|
          format.html do
            content = RenderService.call Page.new(page_params)
            render text: content, layout: false, content_type: 'text/html'
          end
        end
      end

      def publish
        @page = Page.find params[:id]
        @page.publish! author: current_author
        render json: @page, serializer: Landable::PageSerializer
      end

      private

      def page_params
        params.require(:page).permit(:id, :path, :theme_id, :title, :body, :status_code, :redirect_url,
                                     meta_tags: [:description, :keywords, :robots])
      end
    end
  end
end
