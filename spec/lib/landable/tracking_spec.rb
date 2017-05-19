require 'spec_helper'

module Landable
  describe Landable::Traffic::Tracker do
    let(:referer)    { '/something/ valid' }
    let(:user_agent) { 'type' }
    let(:format)     { double('format', html?: true) }
    let(:request)    { double('request', query_parameters: {}, user_agent: user_agent, referer: referer, format: format) }
    let(:controller) { double('controller', request: request) }

    describe '#for' do
      it 'should default to UserTracker if user_agent does not exist' do
        expect(Landable::Traffic::Tracker.for(controller)).to be_a(Landable::Traffic::UserTracker)
      end

      it 'should create the appropriate type of tracker based on user_agent' do
        type = double('type', user_agent_type: 'Scan')
        fake_agent = {}
        fake_agent['type'] = type
        stub_const('Landable::Traffic::UserAgent', fake_agent)

        expect(Landable::Traffic::Tracker.for(controller)).to be_a(Landable::Traffic::ScanTracker)
      end

      it 'should not bark if user_agent is nil' do
        user_agent = nil
        request = double('request', query_parameters: {}, user_agent: user_agent, format: format)
        controller = double('controller', request: request)

        expect(Landable::Traffic::Tracker.for(controller)).to be_a(Landable::Traffic::UserTracker)
      end

      it 'should set type to noop when non-html content' do
        user_agent = nil
        allow(Landable.configuration).to receive(:traffic_enabled).and_return(:html)
        format = double('format', html?: false)
        request = double('request', query_parameters: {}, user_agent: user_agent, format: format)
        controller = double('controller', request: request)

        expect(Landable::Traffic::Tracker.for(controller)).to be_a(Landable::Traffic::NoopTracker)
      end

      it 'should allow non-html content if config says so' do
        format = double('format', html?: false)
        request = double('request', query_parameters: {}, user_agent: user_agent, format: format)
        controller = double('controller', request: request)

        expect(Landable::Traffic::Tracker.for(controller)).to be_a(Landable::Traffic::UserTracker)
      end
    end

    context 'referer' do
      let(:visit_referer) { double('visit_referer', url: 'http://www.fakedomain.yes/mypath', uri: URI('http://www.fakedomain.yes/mypath')) }
      let(:visit) { double('visit', referer: visit_referer) }

      describe '#referer_uri' do
        it 'should encode special characters' do
          tracker = Landable::Traffic::UserTracker.new controller

          expect(tracker.send(:referer_uri).path).to eq '/something/%20valid'
        end
      end

      describe '#visit_referer_domain' do
        it 'should return the domain of the referer' do
          tracker = Landable::Traffic::UserTracker.new controller
          allow(tracker).to receive(:visit) { visit }

          expect(tracker.send(:visit_referer_domain)).to eq 'www.fakedomain.yes'
        end
      end

      describe '#visit_referer_path' do
        it 'should return the path of the referer' do
          tracker = Landable::Traffic::UserTracker.new controller
          allow(tracker).to receive(:visit) { visit }

          expect(tracker.send(:visit_referer_path)).to eq '/mypath'
        end
      end

      describe '#visit_referer_url' do
        it 'should return the full url of the referer' do
          tracker = Landable::Traffic::UserTracker.new controller
          allow(tracker).to receive(:visit) { visit }

          expect(tracker.send(:visit_referer_url)).to eq 'http://www.fakedomain.yes/mypath'
        end
      end
    end

    context 'user_agent' do
      describe '#get_user_agent' do
        context 'user agent provided' do
          let(:user_agent) { Landable::Traffic::UserAgent.new(user_agent: 'dummy_user_agent') }

          it 'should return the user agent' do
            tracker = Landable::Traffic::UserTracker.new controller
            allow(tracker).to receive(:user_agent) { user_agent }

            expect(tracker.send(:get_user_agent)).to eq user_agent
          end
        end

        context 'user agent not provided' do
          it 'should return the user agent' do
            tracker = Landable::Traffic::UserTracker.new controller
            allow(tracker).to receive(:user_agent) { nil }

            expect(tracker.send(:get_user_agent)).to be_nil
          end
        end
      end
    end

    context 'no referer' do
      let(:referer) { double('referer', path: nil) }
      let(:visit) { double('visit', referer: nil) }

      describe '#referer_uri_path' do
        it 'should return empty string' do
          tracker = Landable::Traffic::UserTracker.new controller
          allow(tracker).to receive(:referer_uri) { referer }

          expect(tracker.send(:referer_uri_path)).to eq('')
        end
      end

      describe '#visit_referer_domain' do
        it 'should return nil' do
          tracker = Landable::Traffic::UserTracker.new controller
          allow(tracker).to receive(:visit) { visit }

          expect(tracker.send(:visit_referer_domain)).to be_nil
        end
      end

      describe '#visit_referer_path' do
        it 'should return nil' do
          tracker = Landable::Traffic::UserTracker.new controller
          allow(tracker).to receive(:visit) { visit }

          expect(tracker.send(:visit_referer_path)).to be_nil
        end
      end

      describe '#visit_referer_url' do
        it 'should return nil' do
          tracker = Landable::Traffic::UserTracker.new controller
          allow(tracker).to receive(:visit) { visit }

          expect(tracker.send(:visit_referer_url)).to be_nil
        end
      end
    end
  end
end
