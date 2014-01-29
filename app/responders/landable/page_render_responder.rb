module Landable
  class PageRenderResponder < ActionController::Responder
    def to_html
      page = resource

      case page.status_code
      when 200      then render text: RenderService.call(page, responder: self), content_type: page.content_type, layout: page.theme.try(:file) || false
      when 301, 302 then redirect_to page.redirect_url, status: page.status_code
      when 404      then head 404
      end
    end
  end
end
