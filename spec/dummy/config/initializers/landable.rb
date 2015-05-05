require 'landable'
require Rails.root.join('lib', 'bunny_messaging_service.rb')

Landable.configure do |config|
  config.api_namespace = '/api'
  config.cors.origins  = ['http://cors.test']

  Landable::Engine.routes.default_url_options = { host: 'test.landable.dev' }
  config.sitemap_exclude_categories = %w(Testing)
  config.sitemap_protocol = 'https'
  config.sitemap_additional_paths = %w(/terms.html)
  config.partials_to_templates = %w(partials/foobazz)

  config.reserved_paths = %w(/reserved_path_set_in_initializer /reject/.* /admin.*)
  config.database_schema_prefix = 'dummy'
  config.audit_flags = %w(loans apr)

  config.amqp_configuration = {
    site_segment: 'mybrand:myproduct:myapp',
    messaging_service: BunnyMessagingService,
    enabled: 'true',
    event_mapping: {
      '/' => 'Home page',
      '/my_path' => { 'GET' => 'Customer Landed',
                      'POST' => 'Customer Submitted',
                      'DELETE' => 'Customer Left'
                    }
    }.freeze
  }
end

# Configure asset uploads. Assets will be uploaded to public/uploads by default.
# More configuration options: https://github.com/carrierwaveuploader/carrierwave
CarrierWave.configure do |_config|
  # config.asset_host = 'http://cdn.myapp.com'
end
