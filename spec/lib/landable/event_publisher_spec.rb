require 'spec_helper'

module Landable
  module Traffic
    describe 'EventPublisher' do
      # let(:referer)    { '/something/valid' }
      let(:user_agent) { double('user_agent', { 'id' => 1, 'user_agent' => 'Mac OSX Foo', 'user_agent_type' => 'html'} ) }
      let(:format)     { double('format', { html?: true}) }
      let(:request)    { double('request', { query_parameters: {}, user_agent: user_agent, referer: referer, format: format }) }
      let(:event_mapping)  { double('/my/path' => { 'GET' => 'Customer Landed', 'POST' => 'Customer Left' } ) }
      let(:page_view)   { double( { 'page_view_id' => 1, 'path_id' => 1, 'path' => '/my/path', 'http_method' => 'GET' } ) }
      let(:enabled?)    { true }
      let(:get_owner)   { '10' }
      let(:application_name)  { 'are_you_kidding_me'  }
      let(:controller) { double('controller', { request: request }) }
      let(:visit_referer) { double('visit_referer', { url: 'http://www.fakedomain.yes/mypath', uri: URI("http://www.fakedomain.yes/mypath") }) }
      let(:visit_attribution) { double('attribution_id' => 1)}
      let(:visit_owner) { double('owner', { 'owner_id' => 1, 'owner' => 10 } ) }
      let(:visit) { double('visit', { 'id' => 1, 'cookie_id' => '123abc', 'created_at' => '12/12/2012', 'owner_id' => 1, 'owner' => 10, referer: visit_referer, attribution: visit_attribution}) }
      let(:ip_addr) { double('ip_address', {'id' => 1, 'ip_address' => '10.0.0.0'} ) }
      let(:tracker) { double('tracker', { visit: visit, ip_address: ip_addr, user_agent: user_agent} ) }
      let(:event) { double('event', {'id' => 1, 'event_type' => 'GET'} ) }
      let(:owner) { double('Landable::Traffic::Owner', 'id' => 1, 'owner' => 10 ) }

      describe 'message' do
        it "should return the correct page" do
          allow(tracker).to receive(:create_event) { event }
          allow(Landable::Traffic::Owner).to receive(:find) { owner }
          my_message = EventPublisher.new(tracker, page_view, {}).message
        end
      end

    end
  end
end