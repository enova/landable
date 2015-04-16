require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "landable"
require "hutch"

# Always mount Rack::Schema in test / dev environments.
ENV['LANDABLE_VALIDATE_JSON'] = '1'

module Dummy
  class Application < Rails::Application
    config.active_record.schema_format = :sql
  end
end

