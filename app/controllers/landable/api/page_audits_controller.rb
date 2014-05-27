require_dependency "landable/api_controller"

module Landable
  module Api
    class PageAuditsController < ApiController
      def index
        audits = Audit.where(auditable_id: params[:auditable_id])
        respond_with audits
      end

      def create
        audit = Audit.new audit_params.merge(auditable_id: params[:page_id],
                                             auditable_type: 'Landable::Page')
        audit.save!

        respond_with audit
      end

      def audit_params
        params.require(:page_audit).permit(:id, :approver, :notes, flags: [])
      end
    end
  end
end
