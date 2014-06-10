require_dependency "landable/api_controller"

module Landable
  module Api
    class AuditsController < ApiController
      def index
        determine_which_index
        respond_with @audits
      end

      def show
        respond_with Audit.find(params[:id])
      end

      def create
        determine_type_of_audit
        audit = Audit.new audit_params.merge(auditable_id: @type_id,
                                             auditable_type: @type)
        audit.save!

        respond_with audit, status: :created, location: audit_url(audit)
      end

      private
        def audit_params
          params[:audit][:flags] ||= []
          params.require(:audit).permit(:id, :approver, :notes, :created_at, flags: [])
        end

        def determine_which_index
          if params[:auditable_id].present?
            @audits = Audit.where(auditable_id: params[:auditable_id])
          else
            @audits = Audit.order('created_at DESC')
          end
        end

        def determine_type_of_audit
          if params[:page_id].present?
            @type_id = params[:page_id]
            @type = 'Landable::Page'
          else
            @type_id = params[:template_id]
            @type = 'Landable::Template'
          end
        end
    end
  end
end
