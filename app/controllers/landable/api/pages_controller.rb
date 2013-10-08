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
        page.updated_by_author = current_author
        page.save!
        respond_with page, status: :created, location: page_url(page)
      end

      def show
        respond_with Page.find(params[:id])
      end

      def update
        page = Page.find params[:id]
        page.updated_by_author = current_author
        page.update_attributes! page_params
        respond_with page
      end

      def publish
        page = Page.find params[:id]
        page.publish! author: current_author, notes: params[:notes], is_minor: !!params[:is_minor]
        respond_with page
      end

      def preview
        page  = Page.where(page_id: page_params[:id]).first_or_initialize
        page.attributes = page_params

        # run the validators and render
        if page.valid?
          if layout = page.theme.try(:file) || false
            content = with_format(:html) do
              render_to_string text: RenderService.call(page), layout: layout
            end
          else
            content = RenderService.call(page, preview: true)
          end
        end

        respond_to do |format|
          format.json do
            render json: {
              page: {
                preview: content,
                errors: page.errors,
              }
            }
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
        params.require(:page).permit(:id, :path, :head_tags_attributes, :theme_id, :category_id, :title, :body, :status_code, :redirect_url, :lock_version,
                                     meta_tags: [:description, :keywords, :robots])
      end

      def with_format(format, &block)
        old_formats = formats

        begin
          self.formats = [format]
          return block.call
        ensure
          self.formats = old_formats
        end
      end
    end
  end
end
