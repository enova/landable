require 'spec_helper'

module Landable
  describe PageRevision do
    let(:page) { FactoryGirl.create(:page,
          path: '/test/path',
          title: 'title',
          status_code: 200,
          body: 'body',
          redirect_url: '/redirect/here',
          meta_tags: {'key'=>'value'}
        ) }
    let(:author) { FactoryGirl.create(:author) }

    describe '#page_id=' do
      it 'should set page revision attributes matching the page' do

        page_revision = PageRevision.new
        page_revision.page_id = page.page_id

        page_revision.snapshot_attributes[:attrs].should == page.attributes.reject { |key|
          PageRevision.ignored_page_attributes.include? key
        }
      end

      it 'should have default to is_published = true' do
        PageRevision.new.is_published.should == true
      end
    end

    describe '#snapshot' do
      it 'should build a page based on snapshot_attribute' do
        revision = PageRevision.new
        revision.page_id = page.id

        new_page = revision.snapshot
        new_page.should be_an_instance_of Page
        new_page.title.should == 'title'
        new_page.path.should == '/test/path'

      end

    describe 'is_published' do
      it 'should set is_published to true and false as requested' do
        revision = PageRevision.new
        revision.page_id = page.id
        revision.author_id = author.id
        revision.unpublish!
        revision.is_published.should == false
        revision.publish!
        revision.is_published.should == true
      end
    end
    end
  end
end
