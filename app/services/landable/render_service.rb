module Landable
  class RenderService
    def self.call(controller, page)
      theme  = page.theme
      layout = theme.try(:layout) || 'application'

      reply = if page.status_code == 200 || page.body.present?
                proc { controller.render text: page.body, layout: layout, locals: { current_page: page } }
              else
                proc { controller.head :bad_request }
              end

      controller.respond_to do |format|
        format.html &reply
      end
    end
  end
end
