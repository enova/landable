require_dependency 'landable/liquid'

module Landable
  class RenderService
    def self.call(page)
      template = ::Liquid::Template.parse(page.body)

      registers = {
        asset_prefix: $asset_uri_prefix, # TODO obviously shouldn't be a global
        page:   page,
        assets: page.assets
      }

      content = template.render!(nil, registers: registers)

      if theme_body = page.theme.try(:body)
        template = ::Liquid::Template.parse(theme_body)
        template.render!({ 'body' => content }, registers: registers)
      else
        content
      end
    end
  end
end
