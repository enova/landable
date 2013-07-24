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
        respond_with screenshot, status: :created, location: screenshot_url(screenshot)
      end

      def resubmit
        screenshot = Landable::Screenshot.find(params[:id])
        service = Landable::ScreenshotService.new screenshot.screenshotable
        service.submit_screenshots [screenshot]
        respond_with screenshot
      end

      def callback
        Landable::ScreenshotService.handle_job_callback params.except(:controller, :action)
        head :ok
      end

      def browsers
        render json: {browsers: Landable::ScreenshotService.available_browsers}
      end

      private

      def search_params
        @search_params ||= params.permit(:page_id, :page_revision_id)
      end

      def screenshot_params
        params.require(:screenshot).permit(:page_id, :page_revision_id, :device, :os, :os_version, :browser, :browser_version)
      end
    end
  end
end
