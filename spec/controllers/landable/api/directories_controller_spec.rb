require 'spec_helper'

module Landable
  module Api
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
          ['/a', '/b/c', '/b/d'].map { |path| create :page, path: path }
          make_request
          expect(response.status).to eq 200

          expect(dirs.length).to eq 1
          expect(dirs.first['id']).to eq '/'

          expect(subdirs('/').length).to eq 1
          expect(pages('/').length).to eq 1
        end

        it 'returns multiple directory listings' do
          ['/a', '/b/c', '/b/d', '/c/e', '/c/f/g'].map { |path| create :page, path: path }
          make_request ['/b', '/c']
          expect(response.status).to eq 200
          expect(dirs.length).to eq 2

          expect(pages('/b').length).to eq 2
          expect(pages('/c').length).to eq 1

          expect(subdirs('/b').length).to eq 0
          expect(subdirs('/c').length).to eq 1
        end
      end
    end
  end
end
