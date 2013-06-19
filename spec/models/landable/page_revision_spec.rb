require 'spec_helper'

module Landable
  describe PageRevision do
    describe '#page_id=' do
      it 'should set page revision attributes matching the page' do
        page = FactoryGirl.create(:page,
          path: '/test/path',
          title: 'title',
          status_code: 200,
          body: 'body',
          redirect_url: '/redirect/here',
          meta_tags: {'key'=>'value'}
        )

        page_revision = PageRevision.new
        page_revision.page_id = page.page_id

        page_revision.snapshot_attributes[:attrs].should == page.attributes.reject { |key|
          PageRevision.ignored_page_attributes.include? key
        }
      end
    end

    describe '#snapshot' do
      it 'should build a page based on snapshot_attribute' do
        revision = PageRevision.new
        revision.snapshot_attributes = {
          title: 'title',
          path: '/path/here'
        }

        page = revision.snapshot
        page.should be_an_instance_of Page
        page.title.should == 'title'
        page.path.should == '/path/here'

      end
    end
  end
end
