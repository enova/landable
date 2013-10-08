require 'spec_helper'

module Landable
  describe PageDecorator do
    describe '#head_tag' do
      let(:page) { create :page, head_content: "<head lang='en' />" }

      it 'lists the head_tags seperated by a new line' do
        decorated_page = Landable::PageDecorator.new(page)
        decorated_page.head_content.should == "<head lang='en' />"
      end
    end
  end
end
