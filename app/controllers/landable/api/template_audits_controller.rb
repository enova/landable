require_dependency "landable/api_controller"

module Landable
  module Api
    class TemplateAuditsController < ApiController
      def index
        audits = Audit.where(auditable_id: params[:auditable_id])
        respond_with audits
      end

      def create
        audit = Audit.new audit_params.merge(auditable_id: params[:template_id],
                                             auditable_type: 'Landable::Template')
        audit.save!

        respond_with audit
      end

      def audit_params
        params.require(:template_audit).permit(:id, :approver, :notes, flags: [])
      end
    end
  end
end
