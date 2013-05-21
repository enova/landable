require_dependency "landable/application_controller"

module Landable
  module Api
    class PagesController < ApplicationController
      rescue_from ActiveRecord::RecordInvalid, with: :return_errors

      def create
        @page = Page.new page_params
        @page.save!
        render json: @page, serializer: Landable::PageSerializer, status: :created, location: url_for(@page)
      end

      def show
        @page = Page.find params[:id]
        render json: @page, serializer: Landable::PageSerializer
      end

      def update
        @page = Page.find params[:id]
        @page.update_attributes! page_params
        render json: @page, serializer: Landable::PageSerializer
      end

      def preview
        page = Page.find params[:id]
        render text: page.body, layout: page.theme.try(:layout) || 'application'
      end

      private

      def return_errors(ex)
        render json: { errors: ex.record.errors }, status: :unprocessable_entity
      end

      def page_params
        params.require(:page).permit(:id, :path, :theme, :title, :body, :status_code, :redirect_url)
      end
    end
  end
end
