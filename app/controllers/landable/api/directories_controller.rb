require_dependency "landable/api_controller"

module Landable
  module Api
    class DirectoriesController < ApiController
      def index
        ids = params[:ids] if params[:ids].present? and params[:ids].is_a? Array
        ids ||= ['/']

        listings = ids.map { |id| Directory.listing id }
        render json: listings
      end

      def show
        listing = Directory.listing params[:id]
        render json: listing, serializer: Landable::DirectorySerializer
      end
    end
  end
end
