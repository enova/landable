module Landable
  module Api
    class StatusCodesController < ApiController
      def index
        respond_with StatusCode.all
      end
    end
  end
end
