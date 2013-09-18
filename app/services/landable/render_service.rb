require_dependency 'landable/liquid'

module Landable
  class RenderService
    def self.call(page, options = nil)
      new(page, page.theme, options).render!
    end

    def initialize(page, theme, options = nil)
      @page  = page
      @theme = theme
      @options = options || {}
    end

    def render!
      content = render_template(page.body, {}, registers: {
        page: page,
        assets: assets_for_page,
      })

      if layout?
        content = render_template(theme.body, {'body' => content}, registers: {
          page: page,
          assets: assets_for_theme,
        })
      end

      # not completely happy about this
      if options[:preview]
        preview_template = File.open(Landable::Engine.root.join('app', 'views', 'templates', 'preview.liquid')).read

        content = render_template(preview_template, {
          'content' => content,
          'is_redirect' => page.redirect?,
          'status_code' => page.status_code.code,
          'redirect_url' => page.redirect_url,
        })
      end

      content
    end

    private

    attr_reader :page, :theme, :options

    def layout?
      theme && theme.body.present?
    end

    def parse(body)
      ::Liquid::Template.parse(body)
    end

    def assets_for_page
      @assets_for_page ||=
        begin
          from_theme = theme ? theme.assets_as_hash : {}
          from_theme.merge page.assets_as_hash
        end
    end

    def assets_for_theme
      @assets_for_theme ||= theme ? theme.assets_as_hash : {}
    end

    def render_template template, variables = nil, options = nil
      options ||= {}
      variables ||= {}

      parse(template).render!(variables, options)
    end
  end
end
