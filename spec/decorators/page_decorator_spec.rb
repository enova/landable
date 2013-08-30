require 'spec_helper'

module Landable
  describe PageDecorator do
    describe '#head_tag' do
      let(:head_tag) { create :head_tag }
      let(:page) { head_tag.page }

      it 'lists the head_tags seperated by a new line' do
        head_tag2 = create :head_tag, page: head_tag.page
        decorated_page = Landable::PageDecorator.new(page)
        decorated_page.head_tags.should == "#{head_tag.content}\n#{head_tag2.content}"
      end
    end
  end
end
