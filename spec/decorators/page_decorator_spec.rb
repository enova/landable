require 'spec_helper'

module Landable
  describe PageDecorator do
    describe '#head_content' do
      let(:page) { create :page, head_content: "<head lang='en' />" }

      it 'lists the head_tags seperated by a new line' do
        decorated_page = Landable::PageDecorator.new(page)
        decorated_page.head_content.should == "<head lang='en' />"
      end
    end

    describe '#title' do
      let(:page) { create :page, title: 'title'}

      it 'lists the title' do
        decorated_page = Landable::PageDecorator.new(page)
        decorated_page.title.should == "<title>title</title>"
      end
    end
  end
end
