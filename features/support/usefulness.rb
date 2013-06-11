require 'factory_girl_rails'
require 'pry'

load Landable::Engine.root.join('spec/support/helpers.rb').to_s

World(FactoryGirl::Syntax::Methods)
World(Landable::Spec::CoreHelpers)
World(Landable::Spec::HttpHelpers)

Landable.configure do |c|
  c.authenticators = Landable::AuthenticationService::EchoAuthenticator
end
