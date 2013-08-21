require 'spec_helper'

module Landable::Api
  describe HeadTagsController, json: true do
    routes { Landable::Engine.routes }
    let(:page) { create :page }
    
    describe '#create' do
      include_examples 'Authenticated API controller', :make_request

      let(:default_params) do
        { head_tag: { content: '<head>', page_id: page.id, page: page } }
      end

      def make_request(params = {})
        post :create, default_params.deep_merge(default_params)
      end

      context 'success' do
        it 'returns 201 Created' do
          make_request
          response.status.should == 201
        end

        it 'returns header Location with the page URL' do
          make_request
          response.headers['Location'].should == page_url(default_params[:head_tag][:page_id])
        end

        it 'renders the page as JSON' do
          make_request
          last_json['page'].should include('path' => page.path, 'body' => page.body)
        end
      end

      context 'invalid' do
        it 'returns 422 Unprocessable Entity' do
          invalid_params = { head_tag: { content: nil, page_id: page.id, page: page } }
          post :create, default_params.deep_merge(invalid_params)
          response.status.should == 422
        end
      end
    end

    describe '#update' do
      include_examples 'Authenticated API controller', :make_request

      let(:head_tag) { create :head_tag }
      let(:default_params) do
        { head_tag: { content: '<head>', page_id: page.id, page: page } }
      end

      def make_request(changes = {})
        id = changes.delete(:id) || head_tag.id
        patch :update, default_params.deep_merge(id: id, head_tag: changes)
      end

      it 'saves the changes' do
        make_request content: '<meta>'
        response.status.should == 200
        head_tag.reload.content.should == '<meta>'
      end

      context 'invalid' do
        it 'returns 422 Unprocessable Entity' do
          make_request content: nil
          response.status.should == 422
        end

        it 'includes the errors in the JSON response' do
          make_request status_code_id: Landable::StatusCode.where(code: 302).first.id, redirect_url: nil
        end
      end

      context 'no such page' do
        it 'returns 404' do
          make_request id: random_uuid
          response.status.should == 404
        end
      end
    end
  end
end