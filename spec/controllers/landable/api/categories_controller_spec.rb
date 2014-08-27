require 'spec_helper'

module Landable::Api
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
        response.status.should == 200
        last_json['category']['id'].should == category.id
      end

      it '404s on page not found' do
        make_request random_uuid
        response.status.should == 404
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
        response.status.should == 200
        last_json['categories'].size.should == 5
      end
    end

    describe '#create' do
      include_examples 'Authenticated API controller', :make_request

      let(:default_params) do
        { category: attributes_for(:category) }
      end

      let(:category) do
        Landable::Category.where(name: default_params[:category][:name]).first
      end

      def make_request(params = {})
        post :create, default_params.deep_merge(category: params)
      end

      context 'success' do
        it 'returns 201 Created' do
          make_request
          response.status.should == 201
        end

        it 'returns header Location with the category URL' do
          make_request
          response.headers['Location'].should == category_url(category)
        end

        it 'renders the category as JSON' do
          make_request
          name, description = default_params[:category].values_at(:name, :description)
          last_json['category'].should include('name' => name, 'description' => description)
        end
      end
    end

    describe '#update' do
      include_examples 'Authenticated API controller', :make_request

      let(:category) { create :category }

      def make_request
        put :update, id: category.id, category: { description: "Updated" }
      end

      it "updates the asset description" do
        make_request
        category.reload
        category.description.should == "Updated"
      end
    end
  end
end
