require 'spec_helper'

describe Landable::ApiController, json: true do
  controller(Landable::ApiController) do
    skip_before_action :require_author!, except: [:index]

    def index
      render nothing: true
    end

    def ok
      render nothing: true
    end

    def responder
      respond_with @resource
    end

    def update_responder
      respond_with @resource
    end

    def not_found
      fail ActiveRecord::RecordNotFound
    end

    def xml_only
      respond_to do |format|
        format.xml { render xml: '<lol/>' }
      end
    end

    def record_invalid
      Landable::Page.create!
    end

    def uuid_invalid
      Landable::Page.find('1')
    end

    def other_pg_error
      ActiveRecord::Base.connection.execute 'LOL THIS IS NOT SQL AT ALL GUYS!'
    end
  end

  before do
    routes.draw do
      get 'index'          => 'landable/api#index'
      get 'ok'             => 'landable/api#ok'
      get 'responder'      => 'landable/api#responder'
      patch 'responder'    => 'landable/api#responder'
      put 'responder'      => 'landable/api#responder'
      get 'not_found'      => 'landable/api#not_found'
      get 'xml_only'       => 'landable/api#xml_only'
      get 'record_invalid' => 'landable/api#record_invalid'
      get 'uuid_invalid'   => 'landable/api#uuid_invalid'
      get 'other_pg_error' => 'landable/api#other_pg_error'
    end
  end

  describe 'access token' do
    let(:author) { create :author }
    let(:token)  { create :access_token, author: author }
    let(:headers) do
      { 'HTTP_AUTHORIZATION' => encode_basic_auth(author.username, token.id) }
    end

    def make_request(params = nil)
      request.env.merge!(headers)
      get :index, params
    end

    it 'sets current_author when valid' do
      make_request
      expect(controller.send(:current_author)).to eq author
    end

    it 'must be in the HTTP Authorization header' do
      headers.delete 'HTTP_AUTHORIZATION'
      make_request access_token: token.id
      expect(response.status).to eq 401
    end

    it 'must belong to a valid Author username' do
      headers['HTTP_AUTHORIZATION'] = encode_basic_auth('wrong-username', token.id)
      make_request
      expect(response.status).to eq 401
    end

    it 'must be an existing token ID' do
      headers['HTTP_AUTHORIZATION'] = encode_basic_auth(author.username, token.id.reverse)
      make_request
      expect(response.status).to eq 401
    end

    it 'must not be expired' do
      token.update_attributes(expires_at: 1.minute.ago)
      make_request
      expect(response.status).to eq 401
    end
  end

  context 'rescues RecordNotFound' do
    it 'returns 404 Not Found' do
      get :not_found
      expect(response.status).to eq 404
    end
  end

  context 'rescues RecordInvalid' do
    it 'returns 422 Unprocessable Entity' do
      get :record_invalid
      expect(response.status).to eq 422
    end

    it 'renders ActiveModel::Errors as the JSON response' do
      get :record_invalid
      expect(last_json['errors']).to have_key('path')
    end
  end

  context 'rescues UnknownFormat' do
    it 'returns 406 Not Acceptable' do
      request.env['HTTP_ACCEPT'] = 'text/plain'
      get :xml_only
      expect(response.status).to eq 406
    end
  end

  context 'rescues PG::Errors about invalid UUIDs' do
    it 'returns 404' do
      get :uuid_invalid
      expect(response.status).to eq 404
    end

    it 're-raises any other PG::Error' do
      expect do
        get :other_pg_error
      end.to raise_error(PG::Error)
    end
  end

  describe '#api_media' do
    let(:headers) { {} }

    it 'should match the request format and api version' do
      request.env['HTTP_ACCEPT'] = 'application/xml'

      get :ok

      # sanity check
      expect(request.format.symbol).to eq :xml

      expect(controller.api_media).to eq(format: request.format.symbol,
                                     version: Landable::VERSION::STRING,
                                     param: nil)
    end
  end

  describe 'responder' do
    before(:each) do
      controller.instance_variable_set :@resource, resource
    end

    let(:resource) { create :author }

    it 'should set X-Landable-Media-Type' do
      get :responder
      expect(response.status).to eq 200
      expect(response.headers['X-Landable-Media-Type']).to eq "landable.v#{Landable::VERSION::STRING}; format=json"
    end

    context 'patch' do
      it 'should display the resource' do
        put :responder
        expect(response.body).not_to be_empty
      end
    end

    context 'put' do
      it 'should display the resource' do
        put :responder
        expect(response.body).not_to be_empty
      end
    end
  end
end
