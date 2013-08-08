require_dependency 'landable/liquid'

module Landable
  class RenderService
    def self.call(page)
      new(page, page.theme).render!
    end

    def initialize(page, theme)
      @page  = page
      @theme = theme
    end

    def render!
      content = parse(page.body).render!(nil, registers: {
        page: page
      })

      return content unless layout?

      parse(theme.body).render!({ 'body' => content }, registers: {
        page: page
      })
    end

    private

    attr_reader :page, :theme

    def layout?
      theme && theme.body.present?
    end

    def parse(body)
      ::Liquid::Template.parse(body)
    end
  end
end
