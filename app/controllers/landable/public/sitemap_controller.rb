require_dependency "landable/application_controller"

module Landable
  module Public
    class SitemapController < ApplicationController
      def index
        sitemap = Landable::Page.generate_sitemap

        render xml: sitemap
      end
    end
  end
end
