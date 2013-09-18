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
  end
end
