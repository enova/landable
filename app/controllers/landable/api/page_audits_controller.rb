require_dependency "landable/api_controller"

module Landable
  module Api
    class PageAuditsController < ApiController
      def index
        audits = Audit.where(auditable_id: params[:auditable_id])
        respond_with audits
      end
    end
  end
end
