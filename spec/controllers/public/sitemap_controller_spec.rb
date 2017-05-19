require 'spec_helper'

module Landable
  module Public
    describe SitemapController do
      routes { Landable::Engine.routes }

      it 'returns a 200 status' do
        get :index
        expect(response.status).to eq(200)
      end

      it 'returns xml' do
        get :index
        expect(response.content_type).to eq('application/xml')
      end

      it 'calls generate_sitemap with appropriate arguments' do
        expect(Landable::Page).to receive(:generate_sitemap).with(host: 'test.host',
                                                              protocol: 'https',
                                                              exclude_categories: ['Testing'],
                                                              sitemap_additional_paths: ['/terms.html']).and_call_original
        get :index, format: :xml
      end
    end
  end
end
