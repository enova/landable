require 'spec_helper'

module Landable::Public::Preview
  describe PagesController do
    routes { Landable::Engine.routes }

    describe '#show' do

      let(:page) { create :page, body: '<p>hello</p>', head_content: '<head_content></head_content>' }

      before(:each) do
        page.publish! author: create(:author)
        page.update_attributes! body: '<p>why hello there</p>'
      end

      def make_request
        get :show, id: page.id
      end

      it 'renders the page in situ' do
        make_request
        response.body.should include '<p>why hello there</p>'
      end

      it 'redners the page preview with the head_content' do
        make_request
        response.body.should include '<head_content></head_content>'
      end

      it 'is available at /-/p/:id' do
        assert_recognizes({controller: 'landable/public/preview/pages', action: 'show', id: page.id}, "/-/p/#{page.id}")
      end

    end
  end
end
