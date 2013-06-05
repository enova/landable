module Landable
  module Api
    class PageRevisionsController < ApiController
      def index
        @page_revisions = PageRevision.where(page_id: params[:page_id]).all
        render json: @page_revisions
      end

      def show
        @page_revision = PageRevision.where(page_id: params[:page_id]).find params[:id]
        render json: @page_revision, serializer: Landable::PageRevisionSerializer
      end
    end
  end
end
