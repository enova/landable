module Landable
  module Public
    class PagesController < ApplicationController
      def show
        page = Page.by_path(request.path)
        case page.status_code
        when 200      then render_page(page)
        when 301, 302 then redirect_to page.redirect_url, status: page.status_code
        when 404      then head 404
        end
      end

      private

      def render_page(page)
        theme = page.theme
        render text: page.body, layout: theme.layout
      end
    end
  end
end
