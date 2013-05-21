module Landable
  module Public
    class PagesController < ApplicationController
      def show
        path = Path.by_path(request.path)
        case path.status_code
        when 200 then render_page_at(path)
        when 404 then raise ActiveRecord::RecordNotFound # TODO custom exception
        else raise NotImplementedError
        end
      end

      private

      def render_page_at(path)
        page  = path.page
        theme = Landable.find_theme(page.theme)
        render text: page.body, layout: theme.try(:layout) || 'application'
      end

      def current_path
        @current_path ||= Path.by_path(request.path)
      end
    end
  end
end
