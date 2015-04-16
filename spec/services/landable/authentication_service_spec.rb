require 'spec_helper'

describe Landable::AuthenticationService do
  let(:simple_auth) do
    proc do |username, password|
      if username == 'simple' && password == 'authenticator'
        { username: 'simple', email: 'simple@example.com', first_name: 'Simple', last_name: 'Ton' }
      end
    end
  end

  let(:echo_auth) do
    Landable::AuthenticationService::EchoAuthenticator
  end

  before do
    Landable.configuration.stub(authenticators: [simple_auth, echo_auth])
  end

  it 'returns the result of the first successful authentication strategy' do
    described_class.call('simple', 'authenticator')[:username].should eq 'simple'
    described_class.call('echo', 'echo')[:username].should eq 'echo'
  end

  it 'raises AuthenticationFailedError if no strategy worked' do
    expect do
      described_class.call('will', 'fail')
    end.to raise_error(Landable::AuthenticationFailedError)
  end

  describe 'EchoAuthenticator' do
    it 'returns nil outside of development and test environments' do
      Rails.env.stub(development?: false, test?: false)
      echo_auth.call('would-have', 'worked').should be_nil

      Rails.env.stub(development?: true, test?: false)
      echo_auth.call('will-now', 'work').should_not be_nil

      Rails.env.stub(development?: false, test?: true)
      echo_auth.call('will-now', 'work').should_not be_nil
    end

    it 'returns nil for password "fail"' do
      echo_auth.call('will', 'fail').should be_nil
    end

    it 'returns an author for the given username' do
      entry = echo_auth.call('anyone', 'anything')
      entry.should include(username: 'anyone', email: 'anyone@example.com')
      entry.should have_key(:first_name)
      entry.should have_key(:last_name)
    end

    it 'can be instantiated to only echo a certain username/password' do
      instance = echo_auth.new('trogdor', 'some-pass')
      instance.call('previously', 'worked').should be_nil
      instance.call('trogdor', 'trogdor').should be_nil
      instance.call('trogdor', 'some-pass')[:username].should eq 'trogdor'
    end
  end
end
