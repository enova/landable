require_dependency "landable/api_controller"

module Landable
  module Api
    class DirectoriesController < ApiController
      def index
        ids = params[:ids] if params[:ids].present? and params[:ids].is_a? Array
        ids ||= ['/']

        listings = ids.map { |id| Directory.listing id }
        respond_with listings
      end

      def show
        respond_with Directory.listing(params[:id])
      end
    end
  end
end
