require_dependency 'landable/application_controller'

module Landable
  module Public
    class PagesController < ApplicationController
      respond_to :html

      self.responder = Landable::PageRenderResponder

      def show
        respond_with current_snapshot
      end

      private

      def current_page
        @current_page ||= Page.by_path(request.path)
      end

      def current_snapshot
        @current_snapshot ||= current_page.published_revision.try(:snapshot) || Page.missing
      end
    end
  end
end
