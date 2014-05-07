module Landable
  module Api
    class CategoriesController < ApiController
      def index
        respond_with Category.all
      end

      def show
        respond_with Category.find(params[:id])
      end
    end
  end
end
