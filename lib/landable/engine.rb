require "rack/cors"
require "active_model_serializers"

module Landable
  class Engine < ::Rails::Engine
    isolate_namespace Landable

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    initializer "landable.add_middleware" do |app|
      config = Landable.configuration
      if config.cors.enabled?
        app.middleware.use Rack::Cors do
          allow do
            origins config.cors.origins
            resource "#{config.api_namespace}/*", methods: [:get, :post, :put, :patch, :delete],
              headers: :any,
              credentials: false,
              max_age: 15.minutes
          end
        end
      end
    end
  end
end
