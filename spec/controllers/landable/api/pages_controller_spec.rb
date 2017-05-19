require 'spec_helper'

module Landable
  module Api
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
            expect(response.status).to eq 201
          end

          it 'returns header Location with the page URL' do
            make_request
            expect(response.headers['Location']).to eq page_url(page)
          end

          it 'renders the page as JSON' do
            make_request
            path, body = default_params[:page].values_at(:path, :body)
            expect(last_json['page']).to include('path' => path, 'body' => body)
          end
        end

        context 'invalid' do
          it 'returns 422 Unprocessable Entity' do
            make_request path: nil
            expect(response.status).to eq 422
          end

          it 'includes the errors in the JSON response' do
            make_request status_code: 302, redirect_url: nil
            expect(last_json['errors']).to have_key('redirect_url')
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
          expect(last_json['pages'].collect { |p| p['id'] }.sort).to eq pages.map(&:id).sort
        end

        it 'filters pages according to requested ids' do
          filtered_for_pages = pages[0..2]

          make_request ids: filtered_for_pages.map(&:id)
          expect(last_json['pages'].collect { |p| p['id'] }.sort).to eq filtered_for_pages.map(&:id).sort
        end

        describe 'search' do
          describe 'by path' do
            before(:each) do
              ['/foo', '/foo/bar', '/foo/bar/baz', '/bar'].each do |path|
                create :page, path: path
              end
            end

            it 'filters by starting path fragment' do
              make_request search: { path: '/foo/ba' }
              expect(last_json['pages'].collect { |p| p['path'] }).to eq ['/foo/bar', '/foo/bar/baz']
            end

            it 'matches all paths with the search term in them' do
              make_request search: { path: 'ba' }
              expect(last_json['pages'].collect { |p| p['path'] }).to eq ['/bar', '/foo/bar', '/foo/bar/baz']
            end
          end
        end

        it 'only include 100 results, and include the total result count as meta data' do
          create_list :page, (100 - pages.size)
          make_request search: { path: '/' }

          expect(last_json['pages'].size).to eq 100
          expect(last_json['meta']['search']['total_results']).to eq 100
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
          expect(last_json['page']['body']).to eq page.body
        end

        it 'includes an empty meta_tags hash instead of a null' do
          page.update_attributes meta_tags: nil
          make_request
          expect(last_json['page']['meta_tags']).to eq({})
        end

        context 'no such page' do
          it 'returns 404' do
            make_request random_uuid
            expect(response.status).to eq 404
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
          expect(response.status).to eq 200
          expect(page.reload.body).to eq 'updated body!'
          expect(page.reload.updated_by_author).to eq current_author
        end

        it 'renders the page as JSON' do
          make_request body: 'also updated'
          expect(last_json['page']['body']).to eq 'also updated'
        end

        context 'invalid' do
          it 'returns 422 Unprocessable Entity' do
            make_request path: nil
            expect(response.status).to eq 422
          end

          it 'includes the errors in the JSON response' do
            make_request status_code: 302, redirect_url: nil
          end
        end

        context 'no such page' do
          it 'returns 404' do
            make_request id: random_uuid
            expect(response.status).to eq 404
          end
        end

        context 'stale page' do
          it 'throws error when stale body update' do
            page.save!
            page1 = Landable::Page.first
            page2 = Landable::Page.first

            page1.body = 'duh'
            expect { page1.save! }.to_not raise_error
            page2.body = 'something'
            expect { page2.save! }.to raise_error(ActiveRecord::StaleObjectError)
          end

          it 'throws error when stale meta_tags update' do
            page.save!
            page1 = Landable::Page.first
            page2 = Landable::Page.first

            page1.meta_tags = 'duh'
            expect { page1.save! }.to_not raise_error
            page2.meta_tags = 'something'
            expect { page2.save! }.to raise_error(ActiveRecord::StaleObjectError)
          end

          it 'throws error when stale path update' do
            page.save!
            page1 = Landable::Page.first
            page2 = Landable::Page.first

            page1.body = 'duh'
            expect { page1.save! }.to_not raise_error
            page2.body = 'something'
            expect { page2.save! }.to raise_error(ActiveRecord::StaleObjectError)
          end

          it 'throws error when stale multi-column update' do
            page.save!
            page1 = Landable::Page.first
            page2 = Landable::Page.first
            page1.body = 'duh'
            expect { page1.save! }.to_not raise_error
            page2.body = 'something'
            expect { page2.save! }.to raise_error(ActiveRecord::StaleObjectError)
          end
        end
      end

      describe '#preview', json: false do
        include_examples 'Authenticated API controller', :make_request
        render_views

        let(:theme) { create :theme, body: '<html><head>{% head_content %}</head><body>Theme content; page content: {{body}}</body></html>' }

        before do
          request.env['HTTP_ACCEPT'] = 'text/html'
        end

        def make_request(attributes = attributes_for(:page, theme_id: theme.id))
          post :preview, page: attributes
        end

        it 'renders JSON' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          make_request
          expect(response.status).to eq 200
          expect(last_json['page']['preview']).to be_present
        end

        it 'renders the layout without content if the body is not present' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          make_request attributes_for(:page, body: nil, theme_id: theme.id)
          expect(response.status).to eq 200
          expect(last_json['page']['preview']).to include('Theme content')
        end

        it 'renders without a layout if no theme is present' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          make_request attributes_for(:page, body: 'raw content', theme_id: nil)
          expect(response.status).to eq 200
          expect(last_json['page']['preview']).to include('raw content')
        end

        it 'renders 30x pages with a link to the real thing' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          make_request attributes_for(:page, :redirect, body: 'still here', theme_id: theme.id)
          expect(response.status).to eq 200
          expect(last_json['page']['preview']).to include('301')
        end

        it 'renders 404 pages as if they were 200s' do
          request.env['HTTP_ACCEPT'] = 'application/json'
          make_request attributes_for(:page, :gone, body: 'still here', theme_id: theme.id)
          expect(response.status).to eq 200
          expect(last_json['page']['preview']).to match(/still here/)
        end
      end
    end
  end
end
