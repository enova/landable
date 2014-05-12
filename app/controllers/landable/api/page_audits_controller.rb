require_dependency "landable/api_controller"

module Landable
  module Api
    class PageAuditsController < ApiController
      def index
        page = Page.find(params[:page_id])
        respond_with page.audits
      end

      def create
        audit = Audit.new(approver: params[:approver], notes: params[:notes],
                          auditable_id: params[:page_id], auditable_type: 'Landable::Page')
        audit.save!

        respond_with audit.auditable
      end

      def audit_params
        params.require(:page_audit).permit(:id, :page_id, :approver, :notes)
      end
    end
  end
end