module Landable
  class PageRenderResponder < ActionController::Responder
    content_types = %w(html htm txt json xml)

    content_types.each do |type|
      define_method("to_#{type}") do
        page = resource

        case page.status_code
        when 200      then render text: RenderService.call(page, preview: options[:preview], responder: self),
                                  content_type: page.content_type,
                                  layout: (page.theme.try(:file) || false)
        when 301, 302 then redirect_to page.redirect_url, status: page.status_code
        else          raise page.error
        end
      end
    end
  end
end
