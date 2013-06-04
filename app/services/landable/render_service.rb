module Landable
  class RenderService
    def self.call(controller, page)
      layout   = page.theme.try(:layout) || false
      landable = Landable::PageDecorator.new(page)

      controller.respond_to do |format|
        format.html do
          controller.render text: page.body, layout: layout, locals: { landable: landable }
        end
      end
    end
  end
end
