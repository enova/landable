module Landable
  class RenderService
    def self.call(controller, page)
      theme  = page.theme
      layout = theme.try(:layout) || 'application'

      controller.respond_to do |format|
        format.html do
          controller.render text: page.body, layout: layout, locals: { current_page: page }
        end
      end
    end
  end
end
