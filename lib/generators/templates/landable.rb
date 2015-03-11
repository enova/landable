require 'landable'

Landable.configure do |config|
  # Creates Landable configuration from yaml
  landable_config                   = AppConfig.landable
  landable_environment_config       = landable_config.environment[Rails.env]


  # Specify the hostname(s) of your Publicist instance
  config.cors.origins               = landable_environment_config.origins

  # Simple singleton user authenticator
  # config.authenticator = Landable::AuthenticationService::EchoAuthenticator.new('trogdor', 'trogdor')

  # Set up a custom database schema prefix (default: nil)
  # config.database_schema_prefix = Rails.application.class.parent_name.downcase
  config.database_schema_prefix     = landable_config.schema_prefix

  # Add landable-ldap to your application's Gemfile to authenticate by LDAP:
  # config.authenticator = Landable::LDAP::Authenticator.new(
  #   host: 'ldap.acme.corp',
  #   port: 389,
  #   ssl: 'start_tls',
  #   base: 'ou=user,dc=acme,dc=corp',
  # )

  config.partials_to_templates      = landable_config.partials_to_templates

  # Categories to create (can also be given as a hash to provide descriptions,
  # e.g. {'SEO' => 'Search engine optimization', 'PPC' => 'Pay-per-click'})
  config.categories                 = landable_config.categories

  # Uncomment to enable tracking of all requests.
  # Set to :html to track only HTML requests.
  config.traffic_enabled            = landable_environment_config.traffic_enabled

  # Set up paths that are never tracked by Landable visit tracking
  # config.untracked_paths = %w(/status)
  # Keeps pages with testing category out of sitemap (defaults to [])
  config.sitemap_exclude_categories = landable_config.excluded_categories

  # Configures protocol to be used in sitemap (defaults to 'http')

  config.sitemap_protocol           = landable_config.protocol

  # Configures host name to be used in sitemap (defaults to 'request.host')
  config.sitemap_host               = landable_config.sitemap.host

  # Landable sitemap generator only includes published pages (pages with a published revision) from Landable.  To include other pages, add them as an array like so in your initializer.
  config.sitemap_additional_paths   = landable_config.sitemap.additional_paths

  # TODO: Once templates have been moved change this
  config.reserved_paths             = landable_config.sitemap.additional_paths

  config.audit_flags = landable_config.audit_flags

  # DNT header (http://en.wikipedia.org/wiki/Do_Not_Track)
  #
  # DNT is a proposed HTTP header field that accepts three values:
  #    "1": (opt-out) user does not want to be tracked
  #    "0": (opt-in)  user consents to being tracked
  #   null: (no header, empty, or other) user has not expressed a preference
  #
  # Note: It is unsettled if the DNT header should apply to first-party tracking.
  #
  # Default: Skip tracking if request.headers["DNT"] == "1"
  #
  # Uncomment to change the default
  # config.dnt_enabled = true
  unless Rails.env.production?
    # If you're using Landable with Publicist, add its url here. (required for screenshots)

    config.publicist_url = landable_environment_config.publicist_url

    # Where is your site deployed? (required for screenshots)
    config.public_url    = landable_environment_config.public_url
  end

  # If you want to save a different UserAgent if the request.user_agent is blank, set it here
  # config.blank_user_agent_string = 'blank'
end

# Configure asset uploads. Assets will be uploaded to public/uploads by default.
# More configuration options: https://github.com/carrierwaveuploader/carrierwave
CarrierWave.configure do |config|
  # config.asset_host = 'http://cdn.myapp.com'
end
