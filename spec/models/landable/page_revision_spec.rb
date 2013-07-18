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

    it 'defaults to is_published = true' do
      PageRevision.new.is_published.should == true
    end

    describe '#page_id=' do
      it 'should set page revision attributes matching the page' do
        attrs = revision.snapshot_attributes[:attrs]
        attrs.should == page.attributes.except(*PageRevision.ignored_page_attributes)
      end

      it "copies the page's assets, preserving aliases" do
        page.attachments.add asset, 'alias-name'

        revision.attachments.to_hash.should == {
          'alias-name' => asset
        }

        revision.save!
        revision.should have(1).asset
        revision.should have(1).asset_attachment
      end
    end

    describe '#snapshot' do
      it 'should build a page based on snapshot_attribute' do
        snapshot = revision.snapshot
        snapshot.should be_new_record
        snapshot.should be_an_instance_of Page
        snapshot.title.should == 'title'
        snapshot.path.should == '/test/path'
      end

      it 'includes the persisted asset associations' do
        page.attachments.add asset, 'alias-name'
        revision = PageRevision.create!(page_id: page.id, author_id: author.id)

        snapshot = revision.snapshot
        snapshot.attachments.to_hash.should == {
          'alias-name' => asset
        }
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
  end
end
