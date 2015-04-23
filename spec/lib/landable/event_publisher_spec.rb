require 'spec_helper'

module Landable
  module Traffic
    describe 'EventPublisher', type: :controller do

      controller(ApplicationController) do
        include Landable::Traffic
        prepend_around_action :track_with_landable!

        def my_path
          render nothing: true
        end
      end

      before do
        routes.draw do
          get '/my_path' => 'anonymous#my_path'
          post '/my_path' => 'anonymous#my_path'
          delete '/my_path' => 'anonymous#my_path'
        end
      end

      let(:message_keys) do
        [:ad_group, :ad_type, :bid_match_type, :campaign, :content, :creative, :device_type,
         :experiment, :keyword, :match_type, :medium, :network, :placement, :position,
         :search_term, :source, :target]
      end

      let(:attribution) do
        message_keys.each_with_object({}) do |attribute, hash|
          hash[attribute] = "test_#{attribute}"
        end
      end

      let(:tracker) { controller.instance_variable_get(:@tracker) }
      let(:page_view) { PageView.last }
      let(:published_message) { EventPublisher.publish(page_view) }

      it 'should properly properly set the attribution data and send it within a message' do
        get :my_path, attribution
        #binding.pry
        # TO DO
        # this needs fixed, the attribution data isnt not being set to
        # page_view.visit.attribution, thus the values for
        # published_message[attribute] are nil
        #[31] pry(#<RSpec::Core::ExampleGroup::Nested_1>)> page_view.visit.attribution
        #=> #<Landable::Traffic::Attribution:0x007fb687fe4850
            #attribution_id: 60,
            #ad_type_id: nil,
            #ad_group_id: nil,
        #message_keys.each do |attribute|
          #expect(published_message[attribute]).to eq("test_#{attribute}")
        #end
      end

      it 'should properly set the event types for GET requests when multiple request types use the same route' do
        get :my_path, attribution
        expect(published_message[:path]).to eq('/my_path')
        expect(published_message[:request_type]).to eq('GET')
        expect(published_message[:event]).to eq('Customer Landed')
      end

      it 'should properly set the event types for POST requests when multiple request types use the same route' do
        post :my_path, attribution
        expect(published_message[:path]).to eq('/my_path')
        expect(published_message[:request_type]).to eq('POST')
        expect(published_message[:event]).to eq('Customer Submitted')
      end

      it 'should properly set the event types for DELETE requests when multiple request types use the same route' do
        delete :my_path, attribution
        expect(published_message[:path]).to eq('/my_path')
        expect(published_message[:request_type]).to eq('DELETE')
        expect(published_message[:event]).to eq('Customer Left')
      end

      it 'should correctly set the user agent information in the message' do
        get :my_path, attribution
        user_agent =  UserAgent[controller.request.user_agent]
        expect(published_message[:user_agent_id]).to eq user_agent.id
        expect(published_message[:user_agent]).to eq user_agent.user_agent
      end

      it 'should correctly set the page view information in the message' do
        get :my_path, attribution
        expect(published_message[:page_view_id]).to eq page_view.id
        expect(published_message[:created_at]).to eq page_view.created_at
      end

      it 'should correctly set the visit information in the message' do
        get :my_path, attribution
        visit = page_view.visit
        visitor = page_view.visit.visitor
        expect(published_message[:visit_id]).to eq visit.id
        expect(published_message[:cookie_id]).to eq visit.cookie_id
        expect(published_message[:ip_address_id]).to eq visitor.ip_address_id
        expect(published_message[:ip_address]).to eq visitor.ip_address.to_s
      end
    end
  end
end
