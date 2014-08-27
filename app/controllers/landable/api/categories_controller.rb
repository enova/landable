module Landable
  module Api
    class CategoriesController < ApiController
      def index
        respond_with Category.all
      end

      def create
        category = Category.new(category_params)
        category.save!

        respond_with category, status: :created, location: category_url(category)
      end

      def update
        category = Category.find(params[:id])
        category.update_attributes!(category_params)

        respond_with category
      end

      def show
        respond_with Category.find(params[:id])
      end

      private
        def category_params
          params.require(:category).permit(:id, :name, :description, :slug)
        end
    end
  end
end
