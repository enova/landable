require_dependency "landable/api_controller"

module Landable
  module Api
    class ScreenshotsController < ApiController
      skip_before_filter :require_author!, only: [:callback]

      def index
        search = Landable::ScreenshotSearchEngine.new search_params.merge(ids: params[:ids])
        respond_with search.results, meta: search.meta
      end

      def show
        respond_with Landable::Screenshot.find(params[:id])
      end

      def create
        screenshot = Screenshot.new screenshot_params
        screenshot.save!

        Landable::ScreenshotService.autorun if Landable.configuration.screenshots.autorun

        respond_with screenshot, status: :created, location: screenshot_url(screenshot)
      end

      def resubmit
        screenshot = Landable::Screenshot.find(params[:id])
        screenshot.update_attributes! state: 'unsent', image_url: nil

        Landable::ScreenshotService.autorun if Landable.configuration.screenshots.autorun

        respond_with screenshot
      end

      def callback
        Landable::ScreenshotService.handle_job_callback params.except(:controller, :action)
        head :ok
      end

      private

      def search_params
        @search_params ||= params.permit(:page_id, :screenshotable_type, :screenshotable_id)
      end

      def screenshot_params
        params.require(:screenshot).permit(:id, :browser_id, :screenshotable_type, :screenshotable_id)
      end
    end
  end
end
