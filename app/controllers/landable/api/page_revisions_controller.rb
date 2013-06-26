require_dependency "landable/api_controller"

module Landable
  module Api
    class PageRevisionsController < ApiController
      skip_before_filter :require_author!, if: proc { |c|
        c.action_name == 'show' && c.request.format == :html
      }

      def index
        page = Page.find(params[:page_id])
        respond_with page.revisions.order(:ordinal).reverse
      end

      def show
        respond_to do |format|
          format.json { respond_with PageRevision.find(params[:id]) }
          format.html do
            page = PageRevision.find(params[:id]).snapshot

            case page.status_code
            when 200      then render text: RenderService.call(page), content_type: 'text/html'
            when 301, 302 then redirect_to page.redirect_url, status: page.status_code
            when 404      then head 404
            end
          end
        end
      end

      def revert_to
        revision = PageRevision.find(params[:id])
        revision.page.revert_to! revision
        respond_with revision
      end
    end
  end
end
