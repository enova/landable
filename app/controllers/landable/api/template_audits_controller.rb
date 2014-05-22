require_dependency "landable/api_controller"

module Landable
  module Api
    class TemplateAuditsController < ApiController
      def index
        template = Template.find(params[:template_id])
        respond_with template.audits
      end

      def create
        audit = Audit.new(approver: params[:approver], notes: params[:notes],
                          auditable_id: params[:template_id], auditable_type: 'Landable::Template')
        audit.save!

        respond_with audit.auditable
      end

      def audit_params
        params.require(:audit).permit(:id, :auditable_id, :auditable_type,
                                      flags: [],
                                      :approver, :note)
      end
    end
  end
end
