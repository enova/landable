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
      app.middleware.use Rack::Cors do
        allow do
          origins Landable.cors_origins
          Landable.cors_resources.each do |path|
            resource path, methods: [:get, :post, :put, :patch, :delete], credentials: false, max_age: 15.minutes
          end
        end
      end
    end
  end
end
