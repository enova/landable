require_dependency "rack/cors"

module Landable
  class Engine < ::Rails::Engine
    isolate_namespace Landable

    initializer "landable.add_middleware" do |app|
      app.middleware.use Rack::Cors do
        allow do
          origins  'publicist.dev'
          resource '/landable/*', methods: [:get, :post, :patch, :delete], credentials: false, max_age: 15.minutes
        end
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end
  end
end
