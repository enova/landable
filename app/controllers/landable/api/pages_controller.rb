require_dependency "landable/api_controller"

module Landable
  module Api
    class PagesController < ApiController
      def index
        search = Landable::PageSearchEngine.new search_params.merge(ids: params[:ids]), limit: 100
        respond_with search.results, meta: search.meta
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
        attrs['head_tags_attributes'].try(:each) { |ht| page.head_tags << HeadTag.find(ht['id']) }
        page.attributes = page_params

        params[:page][:asset_ids].try(:each) do |asset_id|
          page.attachments.add Asset.find(asset_id)
        end

        respond_to do |format|
          format.html do
            content = RenderService.call page
            render text: content, layout: false, content_type: 'text/html'
          end
        end
      end

      def screenshots
        Landable::ScreenshotService.call Page.find(params[:id])

        # "{}" is valid json, which jquery will accept as a successful response. "" is not.
        render json: {}, status: 202
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
        params.require(:page).permit(:id, :path, :head_tags_attributes, :theme_id, :category_id, :title, :body, :status_code_id, :redirect_url,
                                     meta_tags: [:description, :keywords, :robots],
                                     head_tags_attributes: [:id, :page_id, :content])
      end
    end
  end
end
