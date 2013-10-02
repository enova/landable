require_dependency "landable/api_controller"
require_dependency "landable/asset_search_engine"

module Landable
  module Api
    class AssetsController < ApiController
      def index
        search = Landable::AssetSearchEngine.new search_params.merge(ids: params[:ids])
        respond_with search.results, meta: search.meta
      end

      def show
        respond_with Asset.find(params[:id])
      end

      def create
        asset = Asset.new asset_params

        if original = asset.duplicate_of
          head :moved_permanently, location: asset_url(original)
          return
        end

        Asset.transaction do
          asset.author = current_author
          asset.save!
        end

        respond_with asset, status: :created, location: asset_url(asset)
      end

      def update
        asset = Asset.find(params[:id])

        asset.update_attributes! asset_params

        respond_with asset
      end

      private

      def search_params
        @search_params ||=
          begin
            hash = params.permit(search: [:name])
            hash[:search] || {}
          end
      end

      def asset_params
        params.require(:asset).permit(:id, :name, :description, :data, :file)
      end
    end
  end
end
