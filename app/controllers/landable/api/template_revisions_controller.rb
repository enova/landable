require_dependency "landable/api_controller"

module Landable
  module Api
    class TemplateRevisionsController < ApiController

      def index
        template = Template.find(params[:template_id])
        respond_with template.revisions.order(:ordinal).reverse
      end

      def show
        revision = TemplateRevision.find(params[:id])

        respond_to do |format|
          format.json { respond_with revision }
        end
      end

      def revert_to
        revision = TemplateRevision.find(params[:id])
        revision.template.revert_to! revision
        respond_with revision
      end
    end
  end
end
