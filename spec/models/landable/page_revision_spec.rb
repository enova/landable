require 'spec_helper'

module Landable
  describe PageRevision do
    let(:author) { create(:author) }
    let(:asset)  { create(:asset)  }

    let(:page) do
      create(:page, path: '/test/path', title: 'title',
             body: 'body', redirect_url: '/redirect/here',
             meta_tags: {'key'=>'value'})
    end

    let(:revision) do
      PageRevision.new page_id: page.id, author_id: author.id
    end

    it { should be_a HasAssets }

    it 'defaults to is_published = true' do
      PageRevision.new.is_published.should == true
    end

    describe '#page_id=' do
      it 'should set page revision attributes matching the page' do
        attrs = revision.attributes.except('page_revision_id','ordinal','notes','is_minor','is_published','author_id','created_at','updated_at', 'head_tags_attributes', 'page_id')
        attrs.should include(page.attributes.except(*PageRevision.ignored_page_attributes))
      end

      it 'should include head_tags as a hash' do
        ht = create :head_tag, page_id: page.id
        revision.head_tags.should == {ht.head_tag_id => ht.content}
      end
    end

    describe '#snapshot' do
      it 'should build a page based on the cached page attributes' do
        snapshot = revision.snapshot
        snapshot.should be_new_record
        snapshot.should be_an_instance_of Page
        snapshot.title.should == page.title
        snapshot.path.should == page.path
      end
    end

    describe '#is_published' do
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

    describe '#preview_path' do
      it 'should return the preview path' do
        revision.should_receive(:public_preview_page_revision_path) { 'foo' }
        revision.preview_path.should == 'foo'
      end
    end

    describe '#preview_url' do
      it 'should return the preview url' do
        revision.should_receive(:public_preview_page_revision_url) { 'foo' }
        revision.preview_url.should == 'foo'
      end
    end

  end
end
