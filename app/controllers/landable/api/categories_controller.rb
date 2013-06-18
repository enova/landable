module Landable
  module Api
    class CategoriesController < ApiController
      def index
        respond_with Category.all
      end
    end
  end
end
