require_dependency "landable/application_controller"

module Landable
  module Api
    class PagesController < ApplicationController
      def create
        @page = Page.new page_params
        @page.save!
        render json: @page, serializer: Landable::PageSerializer, status: :created, location: url_for(@page)
      end

      def show
        @page = Page.find params[:id]
        render json: @page, serializer: Landable::PageSerializer
      end

      def preview
        page = Page.find params[:id]
        render text: page.body, layout: page.theme.layout
      end

      private

      def page_params
        params.require(:page).permit(:id, :theme, :title, :body)
      end
    end
  end
end
