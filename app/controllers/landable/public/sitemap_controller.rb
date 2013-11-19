require_dependency "landable/application_controller"

module Landable
  module Public
    class SitemapController < ApplicationController
      def index
        host = request.host
        sitemap = Landable::Page.generate_sitemap(host)

        render xml: sitemap
      end
    end
  end
end
