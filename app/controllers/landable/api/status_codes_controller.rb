module Landable
  module Api
    class StatusCodesController < ApiController
      def index
        respond_with StatusCode.all
      end

      def show
        respond_with StatusCode.find(params[:id])
      end
    end
  end
end
