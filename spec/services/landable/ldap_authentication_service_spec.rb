require 'spec_helper'

describe Landable::LdapAuthenticationService do
  def build(user, pass)
    described_class.new(user, pass).tap do |service|
      service.with_ldap { Landable::Mock::LdapClient.new }
    end
  end

  it "returns attributes sufficient to find or create an author" do
    attributes = build('trogdor', 'trogdor').authenticate!
    attributes.keys.should include(:username, :email, :first_name, :last_name)
  end

  it "raises without username" do
    expect {
      build(nil, 'password').authenticate!
    }.to raise_error(Landable::LdapAuthenticationService::LdapAuthenticationError)
  end

  it "raises without password" do
    expect {
      build('trogdor', nil).authenticate!
    }.to raise_error(Landable::LdapAuthenticationService::LdapAuthenticationError)
  end

  it "raises without matching LDAP entry" do
    expect {
      service = build('trogdor', 'password')
      service.ldap.entry_generator = proc { nil }
      service.authenticate!
    }.to raise_error(Landable::LdapAuthenticationService::LdapAuthenticationError)
  end

  it "raises if LDAP authentication fails" do
    expect {
      build('trogdor', 'fail').authenticate!
    }.to raise_error(Landable::LdapAuthenticationService::LdapAuthenticationError)
  end
end
