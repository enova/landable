require_dependency "landable/application_controller"

module Landable
  module Api
    class TemplatesController < ApplicationController
      def index
        raise NotImplementedError
      end

      def show
        raise NotImplementedError
      end
    end
  end
end
