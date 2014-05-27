require_dependency "landable/api_controller"

module Landable
  module Api
    class AuditsController < ApiController
      def index
        audits = Audit.all
        respond_with audits
      end

      def show
        respond_with Audit.find(params[:id])
      end
    end
  end
end
