require 'spec_helper'

module Landable
  describe Landable::Traffic::Tracker do
    let(:referer) { "/something/ valid" }
    let(:user_agent) { "type" }
    let(:format) { double('format', { html?: true}) }
    let(:request) { double('request', { query_parameters: {}, user_agent: user_agent, referer: referer, format: format }) }
    let(:controller) { double('controller', { request: request }) }

    describe "#for" do
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
        request = double('request', { query_parameters: {}, user_agent: user_agent, format: format })
        controller = double('controller', { request: request })

        Landable::Traffic::Tracker.for(controller).should be_a(Landable::Traffic::UserTracker)
      end

      it 'should set type to noop when non-html content' do
        user_agent = nil
        Landable.configuration.stub(:traffic_enabled).and_return(:html)
        format = double('format', { html?: false })
        request = double('request', { query_parameters: {}, user_agent: user_agent, format: format })
        controller = double('controller', { request: request })

        Landable::Traffic::Tracker.for(controller).should be_a(Landable::Traffic::NoopTracker)
      end

      it 'should allow non-html content if config says so' do
        format = double('format', { html?: false})
        request = double('request', { query_parameters: {}, user_agent: user_agent, format: format })
        controller = double('controller', { request: request })

        Landable::Traffic::Tracker.for(controller).should be_a(Landable::Traffic::UserTracker)
      end
    end

    describe '#referer_uri' do
      it 'should encode special characters' do
        tracker = Landable::Traffic::UserTracker.new controller

        tracker.send(:referer_uri).path.should == "/something/%20valid"
      end
    end

  end

end
