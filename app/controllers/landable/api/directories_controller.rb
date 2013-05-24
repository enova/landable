require_dependency "landable/application_controller"

module Landable
  module Api
    class DirectoriesController < ApiController
      def index
        listing = Directory.listing(params[:path] || '/')
        render json: listing, serializer: Landable::DirectorySerializer
      end
    end
  end
end
