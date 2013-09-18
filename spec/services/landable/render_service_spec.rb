require 'spec_helper'

module Landable
  describe RenderService do
    let(:page)  { build  :page, body: 'render test', theme: theme }
    let(:theme) { create :theme }

    def render(*args)
      options = args.extract_options!
      target = args.first || page

      RenderService.call(target, options)
    end

    it 'returns a string' do
      page.body = 'Hi mom'
      theme.body = '{{body}}'
      render.should == 'Hi mom'
    end

    context 'without a theme' do
      it 'returns the bare page body' do
        page.theme = nil
        render.should == page.body
      end

      it 'returns the bare page body if the theme is defined, but has no liquid body template' do
        page.theme.body = nil
        render.should == page.body
      end

      it 'returns an empty string if there is also no page body' do
        page.theme = nil
        page.body = nil
        render.should == ''
      end
    end

    context 'without a body' do
      it 'renders the bare theme' do
        theme.body = 'foo {{body}}'
        page.body  = nil
        render.should == 'foo '
      end
    end

    context 'for a redirect' do
      let(:page)  { build :page, :redirect  }

      context 'previewing' do
        let(:rendered) { render(preview: true) }

        it 'conveys information about the redirect' do
          rendered.should include "#{page.status_code.code}"
          rendered.should include "<a href=\"#{page.redirect_url}\">#{page.redirect_url}</a>"
        end
      end

      context 'not previewing' do
        let(:rendered) { render }

        it 'should not include those things' do
          rendered.should_not include "#{page.status_code.code}"
          rendered.should_not include "<a href=\"#{page.redirect_url}\">#{page.redirect_url}</a>"
        end
      end
    end

    context 'for non-html' do
      let(:page) { build :page, body: 'render test', path: 'foo.txt', theme: theme }

      it 'renders without a theme' do
        render.should == 'render test'
      end
    end
  end
end
