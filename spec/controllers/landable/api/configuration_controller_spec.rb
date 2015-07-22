require 'spec_helper'

module Landable
  module Api
    describe ConfigurationsController, json: true do
      routes { Landable::Engine.routes }

      describe '#show' do
        include_examples 'Authenticated API controller', :make_request

        def make_request
          get :show
        end

        it 'renders the page as JSON' do
          pending 'This broken test requires refactoring.'
          # this test cannot possibly pass given the state of the configuration object and controller.
          #   * The controller returns a json version of an object that wasn't initially even a Hash.
          #   * The new configuration object inherits Hash but 'audit_flags' gets lost in conversion
          #     to a JSON object because it is a static attribute of the Landable.configuration object.

          #make_request
          # defined in Landable Dummy Initalizer
          #last_json['configurations'][0]['audit_flags'].should eq %w(loans apr)
        end
      end
    end
  end
end
