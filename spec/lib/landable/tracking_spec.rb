require 'spec_helper'

module Landable
  describe Landable::Traffic::Tracker do
    let(:referer) { '/something/ valid' }
    let(:user_agent) { 'type' }
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

    context 'referer' do
      let(:visit_referer) { double('visit_referer', { domain: 'www.fakedomain.yes', path: '/mypath' }) }
      let(:visit) { double('visit', { referer: visit_referer }) }

      describe '#referer_uri' do
        it 'should encode special characters' do
          tracker = Landable::Traffic::UserTracker.new controller

          tracker.send(:referer_uri).path.should == "/something/%20valid"
        end
      end

      describe '#get_referer_domain' do
        it 'should return the domain of the referer' do
          tracker = Landable::Traffic::UserTracker.new controller
          tracker.stub(:visit) { visit }

          tracker.send(:get_referer_domain).should == 'www.fakedomain.yes'
        end
      end

      describe '#get_referer_path' do
        it 'should return the path of the referer' do
          tracker = Landable::Traffic::UserTracker.new controller
          tracker.stub(:visit) { visit }

          tracker.send(:get_referer_path).should == '/mypath'
        end
      end

      describe '#get_referer_url' do
        it 'should return the full url of the referer' do
          tracker = Landable::Traffic::UserTracker.new controller
          tracker.stub(:visit) { visit }

          tracker.send(:get_referer_url).should == 'www.fakedomain.yes/mypath'
        end
      end
    end

  end

end
