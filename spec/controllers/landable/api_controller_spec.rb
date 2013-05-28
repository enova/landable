require 'spec_helper'

describe Landable::ApiController, json: true do
  controller(Landable::ApiController) do
    skip_before_filter :require_author!, except: [:index]

    def index
      render nothing: true
    end

    def not_found
      raise ActiveRecord::RecordNotFound
    end

    def xml_only
      respond_to do |format|
        format.xml { render xml: '<lol/>' }
      end
    end

    def record_invalid
      Landable::Page.create!
    end
  end

  before do
    routes.draw do
      get 'index' => 'anonymous#index'
      get 'not_found' => 'anonymous#not_found'
      get 'xml_only'  => 'anonymous#xml_only'
      get 'record_invalid' => 'anonymous#record_invalid'
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

    it "sets current_author when valid" do
      make_request
      controller.send(:current_author).should == author
    end

    it "must be in the HTTP Authorization header" do
      headers.delete 'HTTP_AUTHORIZATION'
      make_request access_token: token.id
      response.status.should == 401
    end

    it "must belong to a valid Author username" do
      headers['HTTP_AUTHORIZATION'] = encode_basic_auth('wrong-username', token.id)
      make_request
      response.status.should == 401
    end

    it "must be an existing token ID" do
      headers['HTTP_AUTHORIZATION'] = encode_basic_auth(author.username, token.id.reverse)
      make_request
      response.status.should == 401
    end

    it "must not be expired" do
      token.update_attributes(expires_at: 1.minute.ago)
      make_request
      response.status.should == 401
    end
  end

  context 'rescues RecordNotFound' do
    it 'returns 404 Not Found' do
      get :not_found
      response.status.should == 404
    end
  end

  context 'rescues RecordInvalid' do
    it 'returns 422 Unprocessable Entity' do
      get :record_invalid
      response.status.should == 422
    end

    it 'renders ActiveModel::Errors as the JSON response' do
      get :record_invalid
      last_json['errors'].should have_key('path')
    end
  end

  context 'rescues UnknownFormat' do
    it 'returns 406 Not Acceptable' do
      request.env['HTTP_ACCEPT'] = 'text/plain'
      get :xml_only
      response.status.should == 406
    end
  end
end
