require 'spec_helper'

describe Landable::ApiController, api: true do
  controller(Landable::ApiController) do
    def index
      render nothing: true
    end
  end

  describe 'access token' do
    before do
      routes.draw { get 'index' => 'anonymous#index' }
    end

    let(:author) { create :author }
    let(:token)  { create :access_token, author: author }
    let(:headers) do
      { 'HTTP_AUTHORIZATION' => encode_basic_auth(author.username, token.id) }
    end

    def do_get(params = nil)
      request.env.merge!(headers)
      get :index, params
    end

    it "sets current_author when valid" do
      do_get
      controller.send(:current_author).should == author
    end

    it "must be in the HTTP Authorization header" do
      headers.delete 'HTTP_AUTHORIZATION'
      do_get access_token: token.id
      response.status.should == 401
    end

    it "must belong to a valid Author username" do
      headers['HTTP_AUTHORIZATION'] = encode_basic_auth('wrong-username', token.id)
      do_get
      response.status.should == 401
    end

    it "must be an existing token ID" do
      headers['HTTP_AUTHORIZATION'] = encode_basic_auth(author.username, token.id.reverse)
      do_get
      response.status.should == 401
    end

    it "must not be expired" do
      token.update_attributes(expires_at: 1.minute.ago)
      do_get
      response.status.should == 401
    end
  end
end
