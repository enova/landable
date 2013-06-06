module Landable
  AuthenticationFailedError = Class.new(StandardError)

  module AuthenticationService
    def self.call(username, password)
      strategies = Landable.configuration.authenticators

      strategies.each do |strategy|
        ident = strategy.call username, password
        return ident if ident
      end

      raise AuthenticationFailedError
    end

    class EchoAuthenticator
      def self.call(username, password)
        new(nil, nil).call(username, password)
      end

      def initialize(username, password)
        @username = username
        @password = password
      end

      def call(username, password)
        return unless acceptable_environment?
        return echo_author(username) if @username.nil? && password != 'fail'
        return echo_author(username) if @username == username && @password == password
      end

      private

      def acceptable_environment?
        defined?(::Rails) && (Rails.env.development? || Rails.env.test?)
      end

      def echo_author(username)
        { username: username, email: "#{username}@example.com",
          first_name: 'Trogdor', last_name: 'McBurninator' }
      end
    end
  end
end
