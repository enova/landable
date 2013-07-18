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
        revision = PageRevision.find(params[:id])

        respond_to do |format|
          format.json { respond_with revision }
          format.html { respond_with revision.snapshot, responder: Landable::PageRenderResponder }
        end
      end

      def revert_to
        revision = PageRevision.find(params[:id])
        revision.page.revert_to! revision
        respond_with revision
      end

      def screenshots
        Landable::ScreenshotService.call PageRevision.find(params[:id])

        # "{}" is valid json, which jquery will accept as a successful response. "" is not.
        render json: {}, status: 202
      end
    end
  end
end
