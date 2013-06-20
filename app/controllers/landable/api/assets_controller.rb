require_dependency "landable/api_controller"

module Landable
  module Api
    class AssetsController < ApiController
      def index
        ids   = Array(params[:ids])
        scope = if ids.any?
                  Asset.where(asset_id: ids)
                else
                  Asset.all
                end
        respond_with scope
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
        parent.assets << asset
        respond_with parent
      end

      def destroy
        asset = Asset.find params[:id]
        parent.assets.delete asset
        head :no_content
      end

      private

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
