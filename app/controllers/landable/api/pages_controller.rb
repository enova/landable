require_dependency "landable/api_controller"

module Landable
  module Api
    class PagesController < ApiController
      def index
        search = Landable::PageSearchEngine.new search_params.merge(ids: params[:ids])
        respond_with search.results, meta: { search: search.meta }
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
        attrs = page_params
        page  = attrs[:id].present? ? Page.find(attrs[:id]) : Page.new
        page.attributes = page_params

        respond_to do |format|
          format.html do
            content = RenderService.call page
            render text: content, layout: false, content_type: 'text/html'
          end
        end
      end

      private

      def search_params
        @search_params ||=
          begin
            hash = params.permit(search: [:path])
            hash[:search] || {}
          end
      end

      def page_params
        params.require(:page).permit(:id, :path, :theme_id, :category_id, :title, :body, :status_code, :redirect_url,
                                     meta_tags: [:description, :keywords, :robots])
      end
    end
  end
end
