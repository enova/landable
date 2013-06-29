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
          asset.author    = current_author
          asset.page_ids  = params[:asset][:page_ids]  || []
          asset.theme_ids = params[:asset][:theme_ids] || []
          asset.save!
        end

        respond_with asset, status: :created, location: asset_url(asset)
      end

      def update
        asset = Asset.find params[:id]
        name  = params[:asset].try(:[], :name)
        parent.attachments.add(asset, name)
        respond_with parent
      end

      def destroy
        asset = Asset.find params[:id]
        parent.attachments.delete(asset)
        head :no_content
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
        params.require(:asset).permit(:name, :description, :data)
      end

      def parent
        @parent ||=
          if params[:page_id]
            Page.find(params[:page_id])
          elsif params[:theme_id]
            Theme.find(params[:theme_id])
          else
            raise ActiveRecord::RecordNotFound
          end
      end
    end
  end
end
