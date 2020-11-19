require_dependency 'landable/api_controller'

module Landable
  module Api
    class ThemesController < ApiController
      # filters
      before_action :load_theme, except: [:create, :index, :preview]

      # RESTful methods
      def create
        theme = Theme.new(theme_params)
        theme.save!

        respond_with theme, status: :created, location: theme_url(theme)
      end

      def destroy
        @theme.try(:deactivate)

        respond_with @theme
      end

      def index
        respond_with Theme.all
      end

      def reactivate
        @theme.try(:reactivate)

        respond_with @theme
      end

      def show
        respond_with @theme
      end

      def update
        @theme.update_attributes!(theme_params)

        respond_with @theme
      end

      # custom methods
      def preview
        theme = Theme.new(theme_params)
        page  = Page.example(theme: theme)

        params[:theme][:asset_ids].try(:each) do |asset_id|
          theme.attachments.add Asset.find(asset_id)
        end

        content = render_to_string(
          text: RenderService.call(page),
          layout: page.theme.file || false
        )

        respond_to do |format|
          format.html do
            render text: content, layout: false, content_type: 'text/html'
          end

          format.json do
            render json: { theme: { preview: content } }
          end
        end
      end

      private

      def load_theme
        @theme = Theme.find(params[:id])
      end

      def theme_params
        params.require(:theme).permit(:id, :name, :body, :description, :thumbnail_url)
      end
    end
  end
end
