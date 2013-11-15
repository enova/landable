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
     get 'my_method' => 'anonymous#my_method'
   end
  end
 
  describe 'track_with_landable!' do
   it 'should log errors' do
    tracker = double('tracker')
    transaction = double('transaction')
    stub_const("NewRelic::Agent::Transaction", transaction, :defined? => true)

    Landable::Traffic::Tracker.stub(:for).and_return(tracker)
    tracker.stub(:track).and_raise(TrackError)
    tracker.stub(:save).and_raise(SaveError)

    transaction.should_receive(:notice_error) { |error| error.should be_an_instance_of TrackError }
    transaction.should_receive(:notice_error) { |error| error.should be_an_instance_of SaveError }

    get :my_method
   end
  end
 
 end
 
end