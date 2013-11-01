require 'spec_helper'

module Landable
  describe PageDecorator do
    let(:page_decorator) { Landable::PageDecorator.new(page) }

    describe '#head_content' do
      let(:page) { create :page, head_content: "<head lang='en' />" }

      it 'lists the head_tags seperated by a new line' do
        page_decorator.head_content.should == "<head lang='en' />"
        page_decorator.head_content.should be_html_safe
      end

      context 'nil' do
        let(:page) { create :page, head_content: nil }

        it 'returns nil' do
          page_decorator.head_content.should be_nil
        end
      end
    end

    describe '#title' do
      let(:page) { create :page, title: 'title'}

      it 'lists the title' do
        page_decorator.title.should == "<title>title</title>"
      end
    end
  end
end
