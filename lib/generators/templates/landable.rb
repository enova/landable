require 'landable'

Landable.configure do |config|
  # Specify the hostname(s) of your Publicist instance
  config.cors.origins = %w(publicist.dev)

  # Simple singleton user authenticator
  config.authenticator = Landable::AuthenticationService::EchoAuthenticator.new('trogdor', 'trogdor')

  # Add landable-ldap to your application's Gemfile to authenticate by LDAP:
  # config.authenticator = Landable::LDAP::Authenticator.new(
  #   host: 'ldap.acme.corp',
  #   port: 389,
  #   ssl: 'start_tls',
  #   base: 'ou=user,dc=acme,dc=corp',
  # )
end

# Configure asset uploads. Assets will be uploaded to public/uploads by default.
# More configuration options: https://github.com/carrierwaveuploader/carrierwave
CarrierWave.configure do |config|
  # config.asset_host = 'http://cdn.myapp.com'
end
