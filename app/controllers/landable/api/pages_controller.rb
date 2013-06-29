require_dependency "landable/api_controller"

module Landable
  module Api
    class PagesController < ApiController
      def index
        pages = []
        meta = {}

        # id filtering
        if params[:ids].present? and params[:ids].is_a? Array
          pages = Page.where page_id: params[:ids]

        # searching
        elsif params[:search].present? and params[:search].is_a? Hash

          # ... by path
          if params[:search][:path]
            path = params[:search][:path].to_s
            pages = Page.with_fuzzy_path(path)

            meta[:search] = {
              total_results: pages.count
            }

            pages = pages.limit(50)
          end

        # default to showing all
        else
          pages = Page.all
        end

        respond_with pages, meta: meta
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

      def page_params
        params.require(:page).permit(:id, :path, :theme_id, :category_id, :title, :body, :status_code, :redirect_url,
                                     meta_tags: [:description, :keywords, :robots])
      end
    end
  end
end
