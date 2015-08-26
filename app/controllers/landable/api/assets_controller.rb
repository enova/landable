require_dependency 'landable/api_controller'
require_dependency 'landable/asset_search_engine'

module Landable
  module Api
    class AssetsController < ApiController
      # filters
      before_filter :load_asset, except: [:create, :index]

      # RESTful methods
      def create
        asset = Asset.new(asset_params)
        original = asset.duplicate_of

        if original
          head :moved_permanently, location: asset_url(original)
          return
        end

        Thread.new do
          Asset.transaction do
            asset.author = current_author
            asset.save!
          end
        end

        respond_with asset, status: :created, location: asset_url(asset)
      end

      def destroy
        @asset.try(:deactivate)

        respond_with @asset
      end

      def index
        search = Landable::AssetSearchEngine.new(search_params.merge(ids: params[:ids]))
        respond_with search.results, meta: search.meta
      end

      def reactivate
        @asset.try(:reactivate)

        respond_with @asset
      end

      def show
        respond_with @asset
      end

      def update
        @asset.update_attributes!(asset_params)

        respond_with @asset
      end

      # custom methods

      private

      def asset_params
        params.require(:asset).permit(:id, :name, :description, :data, :file)
      end

      def load_asset
        @asset = Asset.find(params[:id])
      end

      def search_params
        @search_params ||=
          begin
            hash = params.permit(search: [:name])
            hash[:search] || {}
          end
      end
    end
  end
end
