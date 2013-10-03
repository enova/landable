require_dependency "landable/application_controller"

module Landable
  module Public
    module Preview
      class PagesController < ApplicationController
        respond_to :html

        def show
          page = Page.find params[:id]
          respond_with page, responder: Landable::PageRenderResponder
        end
      end
    end
  end
end
