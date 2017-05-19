require 'spec_helper'

describe Landable::AuthenticationService do
  let(:simple_auth) do
    proc do |username, password|
      if username == 'simple' && password == 'authenticator'
        { username: 'simple', email: 'simple@example.com', first_name: 'Simple', last_name: 'Ton', groups: ['CreditMe Read-only', 'QuickQuid Editor', 'Netcredit Publisher'] }
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
    expect(described_class.call('simple', 'authenticator')[:username]).to eq 'simple'
    expect(described_class.call('echo', 'echo')[:username]).to eq 'echo'
  end

  it 'raises AuthenticationFailedError if no strategy worked' do
    expect do
      described_class.call('will', 'fail')
    end.to raise_error(Landable::AuthenticationFailedError)
  end

  describe 'EchoAuthenticator' do
    it 'returns nil outside of development and test environments' do
      Rails.env.stub(development?: false, test?: false)
      expect(echo_auth.call('would-have', 'worked')).to be_nil

      Rails.env.stub(development?: true, test?: false)
      expect(echo_auth.call('will-now', 'work')).not_to be_nil

      Rails.env.stub(development?: false, test?: true)
      expect(echo_auth.call('will-now', 'work')).not_to be_nil
    end

    it 'returns nil for password "fail"' do
      expect(echo_auth.call('will', 'fail')).to be_nil
    end

    it 'returns an author for the given username' do
      entry = echo_auth.call('anyone', 'anything')
      expect(entry).to include(username: 'anyone', email: 'anyone@example.com')
      expect(entry).to have_key(:first_name)
      expect(entry).to have_key(:last_name)
    end

    it 'can be instantiated to only echo a certain username/password' do
      instance = echo_auth.new('trogdor', 'some-pass')
      expect(instance.call('previously', 'worked')).to be_nil
      expect(instance.call('trogdor', 'trogdor')).to be_nil
      expect(instance.call('trogdor', 'some-pass')[:username]).to eq 'trogdor'
    end
  end
end
