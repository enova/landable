require "rack/cors"
require "active_model_serializers"
require "deject"

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
            resource path, methods: [:get, :post, :put, :patch, :delete],
              headers: :any,
              credentials: false,
              max_age: 15.minutes
          end
        end
      end
    end

    initializer "landable.dependency_injection" do |app|
      if Rails.env.development?
        Landable::Api::AccessTokensController.override(:ldap_service) do |controller|
          params = controller.params
          LdapAuthenticationService::DevelopmentMock.new(params[:username], params[:password])
        end
      end
    end
  end
end
