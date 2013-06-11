require_dependency "landable/api_controller"

module Landable
  module Api
    class PageRevisionsController < ApiController
      def index
        page = Page.find(params[:page_id])
        respond_with page.revisions
      end

      def show
        respond_with PageRevision.find(params[:id])
      end

      def revert_to
        revision = PageRevision.find(params[:id])
        revision.page.revert_to! revision
        respond_with revision
      end
    end
  end
end
