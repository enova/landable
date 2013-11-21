require 'spec_helper'

module Landable
  describe Landable::Traffic::Tracker do

    describe "#for" do
      let(:user_agent) { "type" }
      let(:request) { double('request', { query_parameters: {}, user_agent: user_agent }) }
      let(:controller) { double('controller', { request: request }) }

      it 'should default to UserTracker if user_agent does not exist' do
        Landable::Traffic::Tracker.for(controller).should be_a(Landable::Traffic::UserTracker)
      end

      it 'should create the appropriate type of tracker based on user_agent' do
        type = double('type', { user_agent_type: "Scan" }) 
        fake_agent = {}
        fake_agent["type"] = type
        stub_const("Landable::Traffic::UserAgent", fake_agent)

        Landable::Traffic::Tracker.for(controller).should be_a(Landable::Traffic::ScanTracker)
      end

      it 'should not bark if user_agent is nil' do
        user_agent = nil
        request = double('request', { query_parameters: {}, user_agent: user_agent })
        controller = double('controller', { request: request })

        Landable::Traffic::Tracker.for(controller).should be_a(Landable::Traffic::UserTracker)
      end
    end

  end
end