require_dependency 'landable/liquid'

module Landable
  class RenderService
    def self.call(page)
      new(page, page.theme).render!
    end

    def initialize(page, theme)
      @page   = page
      @theme  = theme
    end

    def render!
      content = parse(@page.body).render!(nil, registers: {
        page: @page,
        assets: assets_for_page
      })

      return content unless layout?

      parse(@theme.body).render!({ 'body' => content }, registers: {
        page: @page,
        assets: assets_for_theme
      })
    end

    private

    def assets_for_page
      @assets_for_page ||=
        begin
          prefixed = assets_for_theme.map { |k, v| ["theme/#{k}", v] }
          Hash[prefixed].merge reduce_assets(@page.page_assets)
        end
    end

    def assets_for_theme
      @assets_for_theme ||= themed? ? reduce_assets(@theme.theme_assets) : {}
    end

    def reduce_assets(relations)
      assets = {}
      relations.each do |rel|
        name = rel.alias || rel.asset.name
        assets[name] = rel.asset
      end
      assets
    end

    def themed?
      @theme.present?
    end

    def layout?
      themed? && !@theme.body.blank?
    end

    def parse(body)
      ::Liquid::Template.parse(body)
    end
  end
end
