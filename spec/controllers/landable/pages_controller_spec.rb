require 'spec_helper'

module Landable
  describe PagesController do

    describe '#index' do
      it 'assigns @pages = Page.all' do
        pages = FactoryGirl.build_list :landable_page, 5
        Page.stub(:all) { pages }

        get :index, use_route: :landable

        assigns(:pages).should == pages
      end

    end

  end
end
