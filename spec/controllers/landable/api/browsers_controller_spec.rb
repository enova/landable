require 'spec_helper'

module Landable::Api
  describe BrowsersController, json: true do
    before { pending }

    routes { Landable::Engine.routes }

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      let(:browsers) { create_list :browser, 5 }

      def make_request
        get :index
      end

      it "returns all browsers" do
        browsers
        make_request
        response.status.should == 200
        last_json['browsers'].length.should == 5
      end
    end

    describe '#show' do
      include_examples 'Authenticated API controller', :make_request

      let(:browser) { create :browser }

      def make_request(id = browser.id)
        get :show, id: id
      end

      it 'returns the selected browser' do
        make_request
        response.status.should == 200
        last_json['browser']['id'].should == browser.id
      end

      it '404s on page not found' do
        make_request random_uuid
        response.status.should == 404
      end
    end
  end
end
