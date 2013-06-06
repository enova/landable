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
      theme.body = '{{landable.body}}'
      render.should == 'Hi mom'
    end

    context 'theme variables' do
      before do
        page.path = '/path/to/a/page'
        page.title = 'test-title'
        page.meta_tags = { keywords: 'foo, bar', robots: 'noarchive, nofollow' }
      end

      specify 'landable.head: title and meta tags' do
        theme.body = '{{landable.head}}'
        render.tap do |result|
          result.should match(/<title>test-title<\/title>/)
          result.should match(/<meta content="foo, bar" name="keywords"/)
          result.should match(/<meta content="noarchive, nofollow" name="robots"/)
        end
      end

      specify 'landable.title: the page title in a <title> tag' do
        theme.body = '{{landable.title}}'
        render.should match(/<title>test-title<\/title>/)
      end

      specify 'landable.meta_tags: the page meta tags as <meta> tag values' do
        theme.body = '{{landable.meta_tags}}'
        render.tap do |result|
          result.should match(/<meta content="foo, bar" name="keywords"/)
          result.should match(/<meta content="noarchive, nofollow" name="robots"/)
        end
      end

      specify 'landable.path: the page path' do
        theme.body = '{{landable.path}}'
        render.should == page.path
      end

      specify 'landable.body: the page body' do
        theme.body = '{{landable.body}}'
        render.should == page.body
      end
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
        theme.body = '{{landable.path}} => {{landable.body}}'
        page.path = '/page/path'
        page.body = nil

        render.should == '/page/path => '
      end
    end
  end
end
