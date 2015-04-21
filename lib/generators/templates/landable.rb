require 'landable'

Landable.configure do |config|
  # Specify the hostname(s) of your Publicist instance
  config.cors.origins = %w(publicist.dev http://publicist.10.224.109.244.xip.io/)

  # Simple singleton user authenticator
  # config.authenticator = Landable::AuthenticationService::EchoAuthenticator.new('trogdor', 'trogdor')

  # Set up a custom database schema prefix (default: nil)
  # config.database_schema_prefix = Rails.application.class.parent_name.downcase

  # Add landable-ldap to your application's Gemfile to authenticate by LDAP:
  # config.authenticator = Landable::LDAP::Authenticator.new(
  #   host: 'ldap.acme.corp',
  #   port: 389,
  #   ssl: 'start_tls',
  #   base: 'ou=user,dc=acme,dc=corp',
  # )

  # Categories to create (can also be given as a hash to provide descriptions,
  # e.g. {'SEO' => 'Search engine optimization', 'PPC' => 'Pay-per-click'})
  config.categories = %w(Affiliates PPC SEO Social Email Traditional)

  # Uncomment to enable tracking of all requests.
  # Set to :html to track only HTML requests.
  # config.traffic_enabled = true

  # Set up paths that are never tracked by Landable visit tracking
  # config.untracked_paths = %w(/status)

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

  # If you're using Landable with Publicist, add its url here. (required for screenshots)
  # config.publicist_url = 'http://publicist.dev/'

  # Where is your site deployed? (required for screenshots)
  # config.public_url = 'http://myapp.dev/'

  # If you want to save a different UserAgent if the request.user_agent is blank, set it here
  # config.blank_user_agent_string = 'blank'

  # Uncomment to enable publishing of events to RabbitMq. This feature requires
  # the mounting application to configure Hutch and have a working RabbitMq
  # instance.
  # config.ampq_enable = true

  # Enable publisher confirms feature of RabbitMq through Hutch
  # config.ampq_enable_confirms = false
  #
  # Set the RabbitMq queue name where messages will be published to.
  # By default events are published to the 'event' queue
  # config.ampq_queue = 'my.queue.name'
  #
  # Set the application name to be appended to your messages.
  # By default, it will be Rails.application.class.parent_name
  # config.ampq_application_name = 'My Awesome Application'
  #
  # Set up the path to event_type mapping for the paths that you want to
  # publish messages for. An example configuration is below:
  # config.ampq_event_mapping = {
  #    '/' => 'Home Page',
  #    '/next_page' => { 'GET' => 'Page 2 Landing', 'POST' => 'Page 2 Submission' },
  #    '/logout' => 'Logout'
  # }

end

# Configure asset uploads. Assets will be uploaded to public/uploads by default.
# More configuration options: https://github.com/carrierwaveuploader/carrierwave#using-amazon-s3
CarrierWave.configure do |config|
  # config.asset_host = 'http://cdn.myapp.com'
end
