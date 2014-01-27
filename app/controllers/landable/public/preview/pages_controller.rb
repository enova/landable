require_dependency "landable/application_controller"

module Landable
  module Public
    module Preview
      class PagesController < ApplicationController
        respond_to :html

        def show
          page = Page.find params[:id]

          content = render_to_string(text: RenderService.call(page, preview: true),
                                     layout: page.theme.file || false)


          respond_to do |format|
            format.html do
              render text: content, layout: false, content_type: 'text/html'
            end
          end
        end
      end
    end
  end
end
