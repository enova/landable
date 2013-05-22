module Landable
  module Public
    class PagesController < ApplicationController
      helper_method :current_page

      def show
        page = current_page
        case page.status_code
        when 200      then render_page(page)
        when 301, 302 then redirect_to page.redirect_url, status: page.status_code
        when 404      then head 404
        end
      end

      private

      def render_page(page)
        theme = page.theme
        render text: page.body, layout: theme.try(:layout) || 'application'
      end

      def current_page
        @current_page ||= Page.by_path(request.path)
      end
    end
  end
end
