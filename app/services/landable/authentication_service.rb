module Landable
  AuthenticationFailedError = Class.new(StandardError)

  module AuthenticationService
    def self.call(username, password)
      auth = Landable.configuration.authenticator
      raise AuthenticationFailedError unless ident = auth.call(username, password)
      ident
    end
  end
end
