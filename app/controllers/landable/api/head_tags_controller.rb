require_dependency "landable/api_controller"

module Landable
  module Api
    class HeadTagsController < ApiController
      def create
        head_tag = HeadTag.new head_tag_params
        head_tag.save!
        respond_with head_tag.page, status: :created, location: page_url(head_tag.page_id)
      end

      def update
        head_tag = HeadTag.find params[:id]
        head_tag.update_attributes! head_tag_params
        respond_with head_tag.page
      end

      private


      def head_tag_params
        params.require(:head_tag).permit(:id, :page_id, :content)
      end
    end
  end
end
