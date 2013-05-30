require 'spec_helper'

describe Landable::Api::AccessTokensController, json: true do
  routes { Landable::Engine.routes }

  describe '#create' do
    let(:ldap) { Landable::Mock::LdapClient.new }

    def service(username, password)
      Landable::LdapAuthenticationService.new(username, password).tap do |service|
        service.with_ldap ldap
      end
    end

    def do_post(username, password)
      controller.with_ldap_service service(username, password)
      post :create, username: username, password: password
    end

    it 'authenticates username and password parameters via LDAP' do
      ldap.should_receive(:auth).and_raise 'working'
      expect {
        do_post 'trogdor', 'anything'
      }.to raise_error(/working/)
    end

    it 'creates an author if none exists' do
      expect {
        do_post 'trogdor', 'anything'
      }.to change { Landable::Author.count }.by(1)
    end

    it 'reuses an existing author record if available' do
      create :author, username: 'trogdor'
      expect {
        do_post 'trogdor', 'anything'
      }.not_to change { Landable::Author.count }
    end

    it 'creates a fresh access token for the author' do
      expect {
        do_post 'trogdor', 'anything'
      }.to change { Landable::AccessToken.count }.by(1)
    end

    it 'renders the token and author as JSON' do
      do_post 'trogdor', 'anything'
      token = JSON.parse(response.body)['access_token']
      token['id'].should == Landable::AccessToken.order('created_at DESC').first.id
      token['author']['username'].should == 'trogdor'
    end

    context 'invalid credentials' do
      it 'returns 401' do
        do_post 'anything', 'fail'
        response.status.should == 401
      end
    end
  end

  describe '#destroy' do
    include_examples 'Authenticated API controller', :make_request
    let(:token) { current_access_token }

    def make_request(id = token.id)
      delete :destroy, id: id
    end

    it 'deletes the token' do
      make_request
      expect(Landable::AccessToken.exists?(token.id)).to be_false
    end

    it 'returns No Content' do
      make_request
      response.status.should == 204
    end

    context 'invalid token' do
      it 'returns 404' do
        make_request random_uuid
        response.status.should == 404
      end
    end
  end
end
