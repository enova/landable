require 'spec_helper'

module Landable::Public
  describe SitemapController do
    routes { Landable::Engine.routes }

    it 'returns a 200 status' do
      get :index
      response.status.should == 200
    end

    it 'returns xml' do
      get :index
      response.content_type.should == 'application/xml'
    end

    it 'calls generate_sitemap with appropriate arguments' do
      Landable::Page.should_receive(:generate_sitemap).with(host: 'test.host', protocol: 'https', exclude_categories: ['Testing']).and_call_original
      get :index, format: :xml
    end
  end
end
