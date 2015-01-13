require 'spec_helper'

module Landable::Api
  describe TemplatesController, json: true do
    routes { Landable::Engine.routes }

    describe '#preview', json: false do
      include_examples 'Authenticated API controller', :make_request
      render_views

      let(:theme) { create :theme, body: '<html><head>{% head_content %}</head><body>Theme content; page content: {{body}}</body></html>' }

      before do
        request.env['HTTP_ACCEPT'] = 'text/html'
      end

      def make_request(attributes = attributes_for(:template, theme_id: theme.id))
        post :preview, template: attributes
      end

      it 'renders JSON' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        make_request
        response.status.should == 200
        last_json['template']['preview'].should be_present
      end

      it 'renders the layout without content if the body is not present' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        make_request attributes_for(:template, body: nil)
        response.status.should == 200
        last_json['template']['preview'].should include('Dummy')
      end

      it 'renders without a layout if no theme is present' do
        request.env['HTTP_ACCEPT'] = 'application/json'
        make_request attributes_for(:page, body: 'raw content')
        response.status.should == 200
        last_json['template']['preview'].should include('raw content')
      end
    end
  end
end
