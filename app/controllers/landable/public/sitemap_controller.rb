require_dependency "landable/application_controller"

module Landable
  module Public
    class SitemapController < ApplicationController
      def index
        sitemap = Landable::Page.generate_sitemap(
          host: Landable.configuration.sitemap_host || request.host,
          protocol: Landable.configuration.sitemap_protocol,
          exclude_categories: Landable.configuration.sitemap_exclude_categories,
          include_pages: Landable.configuration.include_pages,
        )

        render xml: sitemap
      end
    end
  end
end
