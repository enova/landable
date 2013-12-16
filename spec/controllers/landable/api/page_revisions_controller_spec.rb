require 'spec_helper'

module Landable::Api
  describe PageRevisionsController, json: true do
    routes { Landable::Engine.routes }

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      let(:page) { create :page }

      def make_request(page_id = page.id)
        get :index, page_id: page_id
      end

      it "returns all of a page's revisions" do
        page.publish! author: current_author
        make_request
        response.status.should == 200
        last_json['page_revisions'].length.should == 1
      end

      it "404s on page not found" do
        make_request random_uuid
        response.status.should == 404
      end
    end
  end
end
