require 'spec_helper'

module Landable
  describe RenderService do
    let(:page)  { build  :page, body: 'render test', theme: theme }
    let(:theme) { create :theme }

    def render(target = page)
      RenderService.call(target)
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
  end
end
