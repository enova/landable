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
      let(:page_view) { tracker.visit.page_views.last }
      let(:published_message) { EventPublisher.new(tracker, page_view, {}).message }

      it 'should properly properly set the attribution data and send it within a message' do
        get :my_path, attribution
        message_keys.each do |attribute|
          expect(published_message[attribute]).to eq("test_#{attribute}")
        end
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
    end
  end
end
