require_dependency 'landable/api_controller'

module Landable
  module Api
    class PagesController < ApiController
      # filters
      before_action :load_page, except: [:create, :index, :preview]

      # RESTful methods
      def create
        page = Page.new page_params
        page.updated_by_author = current_author
        page.save!

        respond_with page, status: :created, location: page_url(page)
      end

      def destroy
        @page.updated_by_author = current_author
        @page.try(:deactivate)

        respond_with @page
      end

      def index
        search = Landable::PageSearchEngine.new search_params.merge(ids: params[:ids]), limit: 100

        respond_with search.results, meta: search.meta
      end

      def reactivate
        @page.try(:reactivate)

        respond_with @page
      end

      def show
        respond_with @page
      end

      def update
        @page.updated_by_author = current_author
        @page.update_attributes!(page_params)

        respond_with @page
      end

      # custom  methods
      def publish
        @page.publish! author_id: current_author.id, notes: params[:notes], is_minor: !params[:is_minor].nil?

        respond_with @page
      end

      def preview
        page = Page.where(page_id: page_params[:id]).first_or_initialize
        page.attributes = page_params

        # run the validators and render
        content = generate_preview_for(page) if page.valid?

        respond_to do |format|
          format.json do
            render json: {
              page: {
                preview: content,
                errors: page.errors
              }
            }
          end
        end
      end

      def screenshots
        Landable::ScreenshotService.call Page.find(params[:id])

        # '{}' is valid json, which jquery will accept as a successful response. '' is not.
        render json: {}, status: 202
      end

      private

      def load_page
        @page = Page.find(params[:id])
      end

      def search_params
        @search_params ||=
          begin
            hash = params.permit(search: [:path])
            hash[:search] || {}
          end
      end

      def page_params
        params[:page][:audit_flags] ||= []
        params.require(:page).permit(:id, :path, :theme_id,
                                     :category_id, :title,
                                     :head_content, :body,
                                     :status_code, :redirect_url,
                                     :lock_version, :abstract,
                                     :hero_asset_name, :page_name,
                                     audit_flags: [],
                                     meta_tags: [:description, :keywords, :robots])
      end
    end
  end
end
