require "rack/cors"
require "active_model_serializers"
require "carrierwave"
require "rake"

module Landable
  class Engine < ::Rails::Engine
    isolate_namespace Landable


    config.to_prepare do
      Landable::ApplicationController.helper Rails.application.helpers
    end

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_girl, :dir => 'spec/factories'
    end

    initializer "landable.enable_cors" do |app|
      config = Landable.configuration
      if config.cors.enabled?
        app.middleware.insert 0, Rack::Cors do
          allow do
            origins config.cors.origins
            resource "#{config.api_namespace}/*",
              methods: [:get, :post, :put, :patch, :delete],
              headers: :any,
              expose: 'X-Landable-Media-Type',
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

    initializer "landable.seed_required" do |app|
      Landable::Seeds.seed(:required) rescue nil
    end

    initializer "landable.create_themes" do |app|
      Theme.create_from_layouts! rescue nil
    end

    initializer 'landable.create_templates' do |app|
      Template.create_from_partials! rescue nil
    end

    initializer "landable.action_controller" do
      ActiveSupport.on_load :action_controller do
        helper Landable::PagesHelper

        # tracking
        include Landable::Traffic
        if Landable.configuration.traffic_enabled
          prepend_around_action :track_with_landable!
        end
      end
    end

    initializer "landable_register_variable" do
    end
  end
end
