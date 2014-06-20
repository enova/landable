require 'spec_helper'

module Landable::Api
  describe ConfigurationsController, json: true do
    routes { Landable::Engine.routes }

    describe '#show' do
      include_examples 'Authenticated API controller', :make_request

      def make_request
        get :show
      end

      it 'renders the page as JSON' do
        make_request
        # defined in Landable Dummy Initalizer
        last_json['configurations'][0]['audit_flags'].should == %w(loans apr)
      end
    end
  end
end
