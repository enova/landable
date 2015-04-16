require 'spec_helper'

module Landable
  describe RenderService do
    let(:page)  { build :page, body: 'render test', theme: theme }
    let(:theme) { create :theme }

    def render(*args)
      options = args.extract_options!
      target = args.first || page

      RenderService.call(target, options)
    end

    it 'returns a string' do
      page.body = 'Hi mom'
      theme.body = '{{body}}'
      render.should eq 'Hi mom'
    end

    context 'without a theme' do
      it 'returns the bare page body' do
        page.theme = nil
        render.should eq page.body
      end

      it 'returns the bare page body if the theme is defined, but has no liquid body template' do
        page.theme.body = nil
        render.should eq page.body
      end

      it 'returns an empty string if there is also no page body' do
        page.theme = nil
        page.body = nil
        render.should eq ''
      end
    end

    context 'without a body' do
      it 'renders the bare theme' do
        theme.body = 'foo {{body}}'
        page.body  = nil
        render.should eq 'foo '
      end
    end

    context 'for a redirect' do
      let(:page)  { build :page, :redirect  }

      context 'previewing' do
        let(:rendered) { render(preview: true) }

        it 'conveys information about the redirect' do
          rendered.should include "#{page.status_code}"
          rendered.should include "<a href=\"#{page.redirect_url}\">#{page.redirect_url}</a>"
        end
      end

      context 'not previewing' do
        let(:rendered) { render }

        it 'should not include those things' do
          rendered.should_not include "#{page.status_code}"
          rendered.should_not include "<a href=\"#{page.redirect_url}\">#{page.redirect_url}</a>"
        end
      end
    end

    context 'for non-html' do
      let(:page) { build :page, body: 'render test', path: 'foo.txt', theme: theme }

      it 'renders without a theme' do
        render.should eq 'render test'
      end

      context 'previewing' do
        let(:rendered) { render(preview: true) }

        it 'renders with <pre> around the content' do
          rendered.should eq '<pre>render test</pre>'
        end
      end
    end

    context 'with a Responder' do
      # setup
      let(:controller) { double('MockController', fetch_landable_variables: { 'hello_world' => "I'm a Loner, Dottie. A Rebel." }) }
      let(:responder) { double('responder', controller: controller) }
      let(:rendered) { render(responder: responder) }

      # tests
      it 'should include registered variables from an external controller source' do
        # setup
        page.body = '{{hello_world}}'
        # actions
        # expectations
        rendered.should match "I'm a Loner, Dottie. A Rebel."
        # end
      end
      # end
    end
  end
end
