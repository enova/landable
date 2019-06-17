require 'spec_helper'

module Landable
  describe PageDecorator do
    let(:page_decorator) { Landable::PageDecorator.new(page) }

    describe '#title' do
      let(:page) { create :page, title: 'title' }

      it 'lists the title' do
        expect(page_decorator.title).to eq '<title>title</title>'
      end

      context 'nil' do
        let(:page) { create :page, title: nil }

        it 'returns nil' do
          expect(page_decorator.title).to be_nil
        end
      end
    end

    describe '#page_name' do
      let(:page) { create :page, page_name: 'title' }

      it 'lists the page_name' do
        page_decorator.page_name.should == 'title'
      end

      context 'nil' do
        let(:page) { create :page, page_name: nil }

        it 'returns nil' do
          page_decorator.page_name.should be_nil
        end
      end
    end

    describe '#path' do
      let(:page) { create :page, path: '/landable' }

      it 'lists the path' do
        expect(page_decorator.path).to eq '/landable'
      end
    end

    describe '#body' do
      let(:page) { create :page, body: 'Buy pounds for your pocket' }

      it 'lists the body' do
        expect(page_decorator.body).to eq 'Buy pounds for your pocket'
        expect(page_decorator.body).to be_html_safe
      end

      context 'nil' do
        let(:page) { create :page, head_content: nil }

        it 'returns nil' do
          expect(page_decorator.head_content).to be_nil
        end
      end
    end

    describe '#head_content' do
      let(:page) { create :page, head_content: "<head lang='en' />" }

      it 'lists the head_tags seperated by a new line' do
        expect(page_decorator.head_content).to eq "<head lang='en' />"
        expect(page_decorator.head_content).to be_html_safe
      end

      context 'nil' do
        let(:page) { create :page, head_content: nil }

        it 'returns nil' do
          expect(page_decorator.head_content).to be_nil
        end
      end
    end

    describe '#meta_tags' do
      let(:page) { create :page, meta_tags: { content: 'robots', keyword: 'p2p' } }

      it 'lists the meta_tags seperated by a new line' do
        expect(page_decorator.meta_tags).to eq %(<meta content="robots" name="content" />\n<meta content="p2p" name="keyword" />)
        expect(page_decorator.meta_tags).to be_html_safe
      end

      context 'nil' do
        let(:page) { create :page, meta_tags: nil }

        it 'returns nil' do
          expect(page_decorator.meta_tags).to be_nil
        end
      end

      context 'string' do
        let(:page) { create :page, meta_tags: 'I should be a hash!' }

        it 'returns nil' do
          expect(page_decorator.meta_tags).to be_nil
        end
      end
    end
  end
end
