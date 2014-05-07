require_dependency "landable/application_controller"

module Landable
  module Public
    class SitemapController < ApplicationController
      def index
        sitemap = Landable::Page.generate_sitemap(
          host: Landable.configuration.sitemap_host || request.host,
          protocol: Landable.configuration.sitemap_protocol,
          exclude_categories: Landable.configuration.sitemap_exclude_categories,
          sitemap_additional_paths: Landable.configuration.sitemap_additional_paths,
        )

        render xml: sitemap
      end
    end
  end
end
