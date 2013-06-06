require 'spec_helper'

describe Landable::Api::AccessTokensController, json: true do
  routes { Landable::Engine.routes }

  describe '#create' do
    let(:authenticator) do
      proc do |username, password|
        if username == 'landable' && password == 'landable'
          { username: 'landable', email: 'landable@example.com',
            first_name: 'Landable', last_name: 'Test' }
        elsif username == 'landable' && password == 'raise'
          raise 'raise!'
        end
      end
    end

    before do
      Landable.configuration.stub!(authenticator: authenticator)
    end

    def make_request(username, password)
      post :create, username: username, password: password
    end

    it 'authenticates using the configured strategy' do
      expect {
        make_request 'landable', 'raise'
      }.to raise_error(/raise!/)
    end

    it 'creates an author if none exists' do
      expect {
        make_request 'landable', 'landable'
      }.to change { Landable::Author.count }.by(1)
    end

    it 'reuses an existing author record if available' do
      create :author, username: 'landable'
      expect {
        make_request 'landable', 'landable'
      }.not_to change { Landable::Author.count }
    end

    it 'creates a fresh access token for the author' do
      expect {
        make_request 'landable', 'landable'
      }.to change { Landable::AccessToken.count }.by(1)
    end

    it 'renders the token and author as JSON' do
      make_request 'landable', 'landable'
      token = JSON.parse(response.body)['access_token']
      token['id'].should == Landable::AccessToken.order('created_at DESC').first.id
      token['author']['username'].should == 'landable'
    end

    context 'invalid credentials' do
      it 'returns 401' do
        make_request 'landable', 'fail'
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
