module Landable
  class PageRenderResponder < ActionController::Responder
    def to_html
      page = resource

      case page.status_code.code
      when 200
        render text: RenderService.call(page), content_type: page.content_type, layout: page.theme.file || false

      when 301, 302
        redirect_to page.redirect_url, status: page.status_code.code

      when 404
        head 404
      end
    end
  end
end
