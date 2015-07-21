require 'spec_helper'

module Landable
  describe PageDecorator do
    let(:page_decorator) { Landable::PageDecorator.new(page) }

    describe '#title' do
      let(:page) { create :page, title: 'title' }

      it 'lists the title' do
        page_decorator.title.should eq '<title>title</title>'
      end

      context 'nil' do
        let(:page) { create :page, title: nil }

        it 'returns nil' do
          page_decorator.title.should be_nil
        end
      end
    end

    describe '#path' do
      let(:page) { create :page, path: '/landable' }

      it 'lists the path' do
        page_decorator.path.should eq '/landable'
      end
    end

    describe '#body' do
      let(:page) { create :page, body: 'Buy pounds for your pocket' }

      it 'lists the body' do
        page_decorator.body.should eq 'Buy pounds for your pocket'
        page_decorator.body.should be_html_safe
      end

      context 'nil' do
        let(:page) { create :page, head_content: nil }

        it 'returns nil' do
          page_decorator.head_content.should be_nil
        end
      end
    end

    describe '#head_content' do
      let(:page) { create :page, head_content: "<head lang='en' />" }

      it 'lists the head_tags seperated by a new line' do
        page_decorator.head_content.should eq "<head lang='en' />"
        page_decorator.head_content.should be_html_safe
      end

      context 'nil' do
        let(:page) { create :page, head_content: nil }

        it 'returns nil' do
          page_decorator.head_content.should be_nil
        end
      end
    end

    describe '#meta_tags' do
      let(:page) { create :page, meta_tags: { content: 'robots', keyword: 'p2p' } }

      it 'lists the meta_tags seperated by a new line' do
        page_decorator.meta_tags.should eq %(<meta name="content" content="robots" />\n<meta name="keyword" content="p2p" />)
        page_decorator.meta_tags.should be_html_safe
      end

      context 'nil' do
        let(:page) { create :page, meta_tags: nil }

        it 'returns nil' do
          page_decorator.meta_tags.should be_nil
        end
      end

      context 'string' do
        let(:page) { create :page, meta_tags: 'I should be a hash!' }

        it 'returns nil' do
          page_decorator.meta_tags.should be_nil
        end
      end
    end
  end
end
