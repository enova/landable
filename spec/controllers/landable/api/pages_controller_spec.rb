require 'spec_helper'

module Landable::Api
  describe PagesController, json: true do
    routes { Landable::Engine.routes }

    describe '#create' do
      include_examples 'API authentication', :make_request

      let(:default_params) do
        { page: attributes_for(:page) }
      end

      let(:page) do
        Landable::Page.where(path: default_params[:page][:path]).first
      end

      def make_request(params = {})
        post :create, default_params.deep_merge(page: params)
      end

      context 'success' do
        it 'returns 201 Created' do
          make_request
          response.status.should == 201
        end

        it 'returns header Location with the page URL' do
          make_request
          response.headers['Location'].should == page_url(page)
        end

        it 'renders the page as JSON' do
          make_request
          path, body = default_params[:page].values_at(:path, :body)
          last_json['page'].should include('path' => path, 'body' => body)
        end
      end

      context 'invalid' do
        it 'returns 422 Unprocessable Entity' do
          make_request path: nil
          response.status.should == 422
        end

        it 'includes the errors in the JSON response' do
          make_request status_code: 302, redirect_url: nil
          last_json['errors'].should have_key('redirect_url')
        end
      end
    end

    describe '#show' do
      include_examples 'API authentication', :make_request
      let(:page) { @page || create(:page) }

      def make_request(id = page.id)
        get :show, id: id
      end

      it 'renders the page as JSON' do
        make_request
        last_json['page']['body'].should == page.body
      end

      context 'no such page' do
        it 'returns 404' do
          make_request random_uuid
          response.status.should == 404
        end
      end
    end

    describe '#update' do
      include_examples 'API authentication', :make_request
      let(:page) { @page || create(:page) }
      let(:default_params) do
        { page: { body: 'Different body content' } }
      end

      def make_request(changes = {})
        id = changes.delete(:id) || page.id
        patch :update, default_params.deep_merge(id: id, page: changes)
      end

      it 'saves the changes' do
        make_request body: 'updated body!'
        response.status.should == 200
        page.reload.body.should == 'updated body!'
      end

      it 'renders the page as JSON' do
        make_request body: 'also updated'
        last_json['page']['body'].should == 'also updated'
      end

      context 'invalid' do
        it 'returns 422 Unprocessable Entity' do
          make_request path: nil
          response.status.should == 422
        end

        it 'includes the errors in the JSON response' do
          make_request status_code: 302, redirect_url: nil
        end
      end

      context 'no such page' do
        it 'returns 404' do
          make_request id: random_uuid
          response.status.should == 404
        end
      end
    end

    describe '#preview', json: false do
      include_examples 'API authentication', :make_request
      let(:page) { @page || create(:page) }

      before do
        request.env['HTTP_ACCEPT'] = 'text/html'
      end

      def make_request(attributes = attributes_for(:page))
        post :preview, page: attributes
      end

      it 'renders HTML' do
        make_request
        response.status.should == 200
        response.content_type.should == 'text/html'
      end

      it 'does not know how to return JSON' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        make_request
        response.status.should == 406
      end

      context 'page is a redirect' do
        it 'renders the body as normal, if possible' do
          make_request attributes_for(:page, :redirect, body: 'still here')
          response.status.should == 200
          response.content_type.should == 'text/html'
        end

        it 'returns 400 if there is no body' do
          make_request attributes_for(:page, :redirect)
          response.status.should == 400
        end
      end

      context 'page is a 404' do
        it 'renders the body as normal, if possible' do
          make_request attributes_for(:page, :not_found, body: 'still here')
          response.status.should == 200
          response.content_type.should == 'text/html'
        end

        it 'returns 400 if there is no body' do
          make_request attributes_for(:page, :not_found)
          response.status.should == 400
        end
      end
    end
  end
end
