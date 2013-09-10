require "rack/cors"
require "active_model_serializers"
require "carrierwave"

module Landable
  class Engine < ::Rails::Engine
    isolate_namespace Landable

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    initializer "landable.enable_cors" do |app|
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

    initializer "landable.json_schema" do |app|
      if ENV['LANDABLE_VALIDATE_JSON']
        require 'rack/schema'
        app.middleware.use Rack::Schema
      end
    end

    initializer "landable.required_data" do |app|
      okay = Landable::StatusCodeCategory.where(name: 'okay').first_or_create!
      redirect = Landable::StatusCodeCategory.where(name: 'redirect').first_or_create!
      missing = Landable::StatusCodeCategory.where(name: 'missing').first_or_create!

      Landable::StatusCode.where(code: 200).first_or_create!(description: 'OK', status_code_category: okay)
      Landable::StatusCode.where(code: 301).first_or_create!(description: 'Permanent Redirect', status_code_category: redirect)
      Landable::StatusCode.where(code: 302).first_or_create!(description: 'Temporary Redirect', status_code_category: redirect)
      Landable::StatusCode.where(code: 404).first_or_create!(description: 'Not Found', status_code_category: missing)
    end
  end
end
