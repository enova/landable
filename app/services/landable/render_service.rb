require 'liquid'

module Landable
  class RenderService
    def self.call(page)
      landable = Landable::PageDecorator.new(page)
      theme = page.theme

      if theme.try(:body).blank?
        landable.body || ''
      else
        template = Liquid::Template.parse(theme.body)
        template.render!('landable' => landable)
      end
    end
  end
end
