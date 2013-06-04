module Landable
  class RenderService
    def self.call(controller, page)
      theme  = page.theme
      layout = theme.try(:layout) || 'application'
      landable = Landable::PageDecorator.new(page)

      controller.respond_to do |format|
        format.html do
          controller.render text: page.body, layout: layout, locals: { landable: landable }
        end
      end
    end
  end
end
