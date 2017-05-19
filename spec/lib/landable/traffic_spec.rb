require 'spec_helper'

module Landable
  class TrackError < StandardError
  end

  class SaveError < StandardError
  end

  describe Traffic, type: :controller do
    controller(ApplicationController) do
      include Landable::Traffic
      prepend_around_action :track_with_landable!

      def my_method
        render nothing: true
      end
    end

    before do
      routes.draw do
        get 'my_method' => 'landable/application#my_method'
      end
    end

    describe 'track_with_landable!' do
      it 'should log errors' do
        tracker = double('tracker')

        allow(Landable::Traffic::Tracker).to receive(:for).and_return(tracker)
        allow(tracker).to receive(:track).and_raise(TrackError)
        allow(tracker).to receive(:save).and_raise(SaveError)

        expect(controller).to receive(:newrelic_notice_error) { |error| expect(error).to be_an_instance_of TrackError }
        expect(controller).to receive(:newrelic_notice_error) { |error| expect(error).to be_an_instance_of SaveError }

        get :my_method
      end
    end
  end
end
