require_dependency "landable/api_controller"

module Landable
  module Api
    class PagesController < ApiController
      def index
        ids   = Array(params[:ids])
        scope = ids.any? ? Page.where(page_id: ids) : Page.all
        respond_with scope
      end

      def create
        page = Page.new page_params
        page.save!
        respond_with page, status: :created, location: page_url(page)
      end

      def show
        respond_with Page.find(params[:id])
      end

      def update
        page = Page.find params[:id]
        page.update_attributes! page_params
        respond_with page
      end

      def publish
        page = Page.find params[:id]
        page.publish! author: current_author, notes: params[:notes], is_minor: !!params[:is_minor]
        respond_with page
      end

      def preview
        respond_to do |format|
          format.html do
            content = RenderService.call Page.new(page_params)
            render text: content, layout: false, content_type: 'text/html'
          end
        end
      end

      private

      def page_params
        params.require(:page).permit(:id, :path, :theme_id, :title, :body, :status_code, :redirect_url,
                                     meta_tags: [:description, :keywords, :robots])
      end
    end
  end
end
