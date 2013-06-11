require 'spec_helper'

module Landable::Api
  describe DirectoriesController, json: true do
    routes { Landable::Engine.routes }

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      def make_request(ids = nil)
        get :index, ids: ids
      end

      def dirs
        last_json['directories']
      end

      def dir(path)
        dirs.find { |dir| dir['id'] == path }
      end

      def subdirs(path)
        dir(path)['subdirectory_ids']
      end

      def pages(path)
        dir(path)['page_ids']
      end

      it 'defaults to the root path' do
        pages = ['/a', '/b/c', '/b/d'].map { |path| create :page, path: path }
        make_request
        response.status.should == 200

        dirs.length.should == 1
        dirs.first['id'].should == '/'

        subdirs('/').length.should == 1
        pages('/').length.should == 1
      end

      it 'returns multiple directory listings' do
        pages = ['/a', '/b/c', '/b/d', '/c/e', '/c/f/g'].map { |path| create :page, path: path }
        make_request ['/b', '/c']
        response.status.should == 200
        dirs.length.should == 2

        pages('/b').length.should == 2
        pages('/c').length.should == 1

        subdirs('/b').length.should == 0
        subdirs('/c').length.should == 1
      end
    end
  end
end
