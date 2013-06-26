require_dependency "landable/application_controller"

module Landable
  module Public
    class PagesController < ApplicationController
      def show
        page = current_snapshot

        case page.status_code
        when 200      then render text: RenderService.call(page), content_type: 'text/html'
        when 301, 302 then redirect_to page.redirect_url, status: page.status_code
        when 404      then head 404
        end
      end

      private

      def current_page
        @current_page ||= Page.by_path(request.path)
      end

      def current_snapshot
        @current_snapshot ||= current_page.published_revision.try(:snapshot) or Page.missing
      end
    end
  end
end
