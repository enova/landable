require_dependency "landable/api_controller"

module Landable
  module Api
    class TemplatesController < ApiController
      def index
        respond_with Template.all
      end

      def create
        template = Template.new(template_params)
        template.save!
        respond_with template, status: :created, location: template_url(template)
      end

      def show
        respond_with Template.find(params[:id])
      end

      def update
        template = Template.find(params[:id])
        template.update_attributes! template_params
        respond_with template
      end

      private

      def template_params
        params.require(:template).permit(:id, :name, :body, :description, :thumbnail_url)
      end
    end
  end
end
