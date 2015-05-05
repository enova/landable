require 'spec_helper'

module Landable
  module Api
    describe CategoriesController, json: true do
      routes { Landable::Engine.routes }

      describe '#show' do
        include_examples 'Authenticated API controller', :make_request

        let(:category) { create :category }

        def make_request(id = category.id)
          get :show, id: id
        end

        it 'returns the selected category' do
          make_request
          response.status.should eq 200
          last_json['category']['id'].should eq category.id
        end

        it '404s on page not found' do
          make_request random_uuid
          response.status.should eq 404
        end
      end

      describe '#index' do
        include_examples 'Authenticated API controller', :make_request

        def make_request
          get :index
        end

        it 'returns all categories' do
          Landable::Category.delete_all
          create_list :category, 5

          make_request
          response.status.should eq 200
          last_json['categories'].size.should eq 5
        end
      end
    end
  end
end
