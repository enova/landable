require_dependency "landable/application_controller"

module Landable
  module Public
    module Preview
      class PageRevisionsController < ApplicationController
        respond_to :html

        def show
          revision = PageRevision.find params[:id]
          respond_with revision.snapshot, responder: Landable::PageRenderResponder
        end
      end
    end
  end
end