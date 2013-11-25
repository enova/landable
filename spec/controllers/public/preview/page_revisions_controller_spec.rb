require 'spec_helper'

module Landable::Public::Preview
  describe PageRevisionsController do
    routes { Landable::Engine.routes }

    describe '#show' do

      let(:author) { create :author }
      let(:page) { create :page, body: '<p>hello</p>', head_content: '<head_content></head_content>' }
      let(:page_revision) do
        page.publish! author: author
        page.revisions.first
      end

      before(:each) do
        # establish the tested-for revision
        page_revision

        2.times do |i|
          page.update_attributes! body: "update #{i}"
          page.publish! author: author
        end
      end

      def make_request
        get :show, id: page_revision.id
      end

      it 'renders the page revision' do
        make_request
        response.body.should include '<p>hello</p>'
      end

      it 'redners the page revision with the head_content' do
        make_request
        response.body.should include '<head_content></head_content>'
      end

      it 'is available at /-/pr/:id' do
        assert_recognizes({controller: 'landable/public/preview/page_revisions', action: 'show', id: page_revision.id}, "/-/pr/#{page_revision.id}")
      end
    end
  end
end
