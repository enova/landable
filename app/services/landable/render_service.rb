require_dependency 'landable/liquid'

module Landable
  class RenderService
    def self.call(page)
      new(page, page.theme, $asset_uri_prefix || '/').render!
    end

    def initialize(page, theme, asset_uri_prefix)
      @page   = page
      @theme  = theme
      @prefix = asset_uri_prefix
    end

    def render!
      content = parse(@page.body).render!(nil, registers: {
        asset_prefix: @prefix,
        page: @page,
        assets: assets_for_page
      })

      return content unless layout?

      parse(@theme.body).render!({ 'body' => content }, registers: {
        asset_prefix: @prefix,
        page: @page,
        assets: assets_for_theme
      })
    end

    private

    def assets_for_page
      @assets_for_page ||= assets_for_theme.merge reduce_assets(@page.page_assets)
    end

    def assets_for_theme
      @assets_for_theme ||= themed? ? reduce_assets(@theme.theme_assets, 'theme/') : {}
    end

    def reduce_assets(relations, prefix = '')
      assets = {}
      relations.each do |rel|
        name = rel.alias || rel.asset.name
        assets["#{prefix}#{name}"] = rel.asset
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
