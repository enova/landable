require 'spec_helper'

module Landable::Api
  describe PagesController, json: true do
    routes { Landable::Engine.routes }

    describe '#create' do
      include_examples 'Authenticated API controller', :make_request

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

    describe '#index' do
      include_examples 'Authenticated API controller', :make_request

      let(:pages) { @pages ||= create_list(:page, 5) }
      before(:each) { pages }

      def make_request(params = {})
        get :index, params
      end

      it 'renders pages as json' do
        make_request
        last_json['pages'].collect { |p| p['id'] }.sort.should == pages.map(&:id).sort
      end

      it 'filters pages according to requested ids' do
        filtered_for_pages = pages[0..2]

        make_request ids: filtered_for_pages.map(&:id)
        last_json['pages'].collect { |p| p['id'] }.sort.should == filtered_for_pages.map(&:id).sort
      end

      describe 'search' do
        describe 'by path' do
          before(:each) do
            ['/foo', '/foo/bar', '/foo/bar/baz', '/bar'].each do |path|
              create :page, path: path
            end
          end

          it 'filters by starting path fragment' do
            make_request search: {path: '/foo/ba'}
            last_json['pages'].collect { |p| p['path'] }.should == ['/foo/bar', '/foo/bar/baz']
          end

          it 'matches all paths with the search term in them' do
            make_request search: {path: 'ba'}
            last_json['pages'].collect { |p| p['path'] }.should == ['/bar', '/foo/bar', '/foo/bar/baz']
          end
        end
      end

      it 'only include 100 results, and include the total result count as meta data' do
        create_list :page, (100 - pages.size)
        make_request search: {path: '/'}

        last_json['pages'].size.should == 100
        last_json['meta']['search']['total_results'].should == 100
      end
    end

    describe '#show' do
      include_examples 'Authenticated API controller', :make_request
      let(:page) { @page || create(:page) }

      def make_request(id = page.id)
        get :show, id: id
      end

      it 'renders the page as JSON' do
        make_request
        last_json['page']['body'].should == page.body
      end

      it 'includes an empty meta_tags hash instead of a null' do
        page.update_attributes meta_tags: nil
        make_request
        last_json['page']['meta_tags'].should == {}
      end


      context 'no such page' do
        it 'returns 404' do
          make_request random_uuid
          response.status.should == 404
        end
      end
    end

    describe '#update' do
      include_examples 'Authenticated API controller', :make_request

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
      include_examples 'Authenticated API controller', :make_request
      render_views

      let(:theme) { create :theme, body: '<html><body>Theme content; page content: {{body}}</body></html>' }

      before do
        request.env['HTTP_ACCEPT'] = 'text/html'
      end

      def make_request(attributes = attributes_for(:page, theme_id: theme.id))
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

      it 'renders the layout without content if the body is not present' do
        make_request attributes_for(:page, body: nil, theme_id: theme.id)
        response.status.should == 200
        response.content_type.should == 'text/html'
        response.body.should match(/Theme content/)
      end

      it 'renders without a layout if no theme is present' do
        make_request attributes_for(:page, body: 'raw content', theme_id: nil)
        response.status.should == 200
        response.content_type.should == 'text/html'
        response.body.should == 'raw content'
      end

      it 'renders 30x pages as if they were 200s' do
        make_request attributes_for(:page, :redirect, body: 'still here', theme_id: theme.id)
        response.status.should == 200
        response.content_type.should == 'text/html'
        response.body.should match(/still here/)
      end

      it 'renders 404 pages as if they were 200s' do
        make_request attributes_for(:page, :not_found, body: 'still here', theme_id: theme.id)
        response.status.should == 200
        response.content_type.should == 'text/html'
        response.body.should match(/still here/)
      end
    end

    describe '#screenshots' do
      include_examples 'Authenticated API controller', :make_request

      let(:page) { create :page }

      def make_request
        post :screenshots, id: page.id
      end

      it 'invokes ScreenshotService and returns a 202' do
        Landable::ScreenshotService.should_receive(:call).with(page)
        make_request
        response.status.should == 202
      end
    end
  end
end
