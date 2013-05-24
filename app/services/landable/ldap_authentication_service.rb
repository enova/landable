require "net/ldap"

module Landable
  class LdapAuthenticationService
    LdapAuthenticationError = Class.new(StandardError)

    Deject self
    dependency(:ldap) do
      Net::LDAP.new(host: 'ldap.cashnetusa.com', port: 389, ssl: 'start_tls',
                    base: 'ou=user,ou=jabber,ou=auth,dc=cashnetusa,dc=com')
    end

    def self.call(username, password)
      new(username, password).authenticate!
    rescue LdapAuthenticationError
      nil
    end

    def initialize(username, password)
      @username = username
      @password = password
    end

    def authenticate!
      raise LdapAuthenticationError unless @username.present? && @password.present?
      raise LdapAuthenticationError unless entry = ldap_entry(@username)

      ldap.auth entry.dn, @password
      if ldap.bind
        { username:   entry.uid.first,
          email:      entry.mail.first,
          first_name: entry.givenname.first,
          last_name:  entry.sn.first
        }
      else
        raise LdapAuthenticationError
      end
    end

    private

    def ldap_entry(name)
      ldap.search(filter: Net::LDAP::Filter.eq('uid', name)).try(:first)
    end
  end
end
