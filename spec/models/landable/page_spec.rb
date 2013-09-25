require 'spec_helper'

module Landable
  describe Page do
    it { should_not have_valid(:path).when(nil, '') }
    it { should be_a HasAssets }

    it 'should set is_publishable to true on before_save' do
      page = FactoryGirl.build :page, is_publishable: false
      page.save!
      page.is_publishable.should be_true
    end

    specify "#redirect?" do
      Page.new.should_not be_redirect
      Page.new().should_not be_redirect
      Page.new(status_code: StatusCode.where(code: 200).first).should_not be_redirect
      Page.new(status_code: StatusCode.where(code: 404).first).should_not be_redirect

      Page.new(status_code: StatusCode.where(code: 301).first).should be_redirect
      Page.new(status_code: StatusCode.where(code: 302).first).should be_redirect
    end

    describe '#published?' do
      context 'when published' do
        it 'should be true' do
          page = create :page
          page.publish! author: create(:author), notes: 'yo'
          page.should be_published
        end
      end

      context 'when not published' do
        it 'should be false' do
          page = create :page
          page.should_not be_published
        end
      end
    end

    specify '#path_extension' do
      Page.new(path: 'foo').path_extension.should be_nil
      Page.new(path: 'foo.bar').path_extension.should == 'bar'
      Page.new(path: 'foo.bar.baz').path_extension.should == 'baz'
      Page.new(path: 'foo.bar-baz').path_extension.should be_nil
    end

    describe '#content_type' do
      def content_type_for path
        Page.new(path: path).content_type
      end

      it 'should be text/html for html pages' do
        content_type_for('asdf').should == 'text/html'
        content_type_for('asdf.htm').should == 'text/html'
        content_type_for('asdf.html').should == 'text/html'
      end

      it 'should be application/json for json' do
        content_type_for('asdf.json').should == 'application/json'
      end

      it 'should be application/xml for xml' do
        content_type_for('asdf.xml').should == 'application/xml'
      end

      it 'should be text/plain for everything else' do
        content_type_for('foo.bar').should == 'text/plain'
        content_type_for('foo.txt').should == 'text/plain'
      end
    end

    describe '#html?' do
      let(:page) { build :page }

      it 'should be true if content_type is text/html' do
        page.should_receive(:content_type) { 'text/html' }
        page.should be_html
      end

      it 'should be false if content_type is not text/html' do
        page.should_receive(:content_type) { 'text/plain' }
        page.should_not be_html
      end
    end

    describe '#redirect_url' do
      it 'is required if redirect?' do
        page = Page.new status_code: StatusCode.where(code: 301).first
        page.should_not have_valid(:redirect_url).when(nil, '')
        page.should have_valid(:redirect_url).when('http://example.com', '/some/path')
      end

      it 'not required for 200, 404' do
        page = Page.new
        page.should have_valid(:redirect_url).when(nil, '')
      end
    end

    describe '#meta_tags' do
      it { subject.should have_valid(:meta_tags).when(nil) }

      specify "quacks like a Hash" do
        # Note the change from symbol to string; thus, always favor strings.
        page = create :page, meta_tags: { keywords: 'foo' }
        page.meta_tags.keys.should == [:keywords]

        tags = Page.first.meta_tags
        tags.should be_a(Enumerable)
        tags.keys.should == ['keywords']
        tags.values.should == ['foo']
      end
    end

    describe '#path=' do
      it 'ensures a leading "/" on path' do
        Page.new(path: 'foo/bar').path.should == '/foo/bar'
      end

      it 'leaves nil and empty paths alone' do
        Page.new(path: '').path.should == ''
        Page.new(path: nil).path.should == nil
      end
    end

    describe '#publish' do
      let(:page) { FactoryGirl.create :page }
      let(:author) { FactoryGirl.create :author }

      it 'should create a page_revision' do
        expect {page.publish!(author: author)}.to change{page.revisions.count}.from(0).to(1)
      end

      it 'should have the provided author' do
        page.publish! author: author
        revision = page.revisions.last

        revision.author.should == author
      end

      it 'should update the published_revision_id' do
        page.publish! author: author
        revision = page.revisions.last

        page.published_revision.should == revision
      end

      it 'should set is_publishable to false' do
        page.is_publishable = true
        page.publish! author: author
        page.is_publishable.should be_false
      end

      it 'should unset previous revision.is_published' do
        page.publish! author: author
        revision1 = page.published_revision
        page.publish! author: author
        revision1.is_published.should be_false
      end
    end

    describe '#revert_to' do
      let(:page) { FactoryGirl.create :page }
      let(:author) { FactoryGirl.create :author }

      it 'should NOT update published_revision for the page' do
        page.title = 'Bar'
        page.publish! author: author
        revision = page.published_revision

        page.title = 'Foo'
        page.publish! author: author

        page.revert_to! revision

        page.published_revision.id.should_not == revision.id
      end

      it 'should copy snapshot_attributes into the page model' do
        page.title = 'Bar'
        page.publish! author: author
        revision = page.published_revision

        page.title = 'Foo'
        page.head_tags = [create(:head_tag)]
        page.reload
        page.publish! author: author
        page.head_tags.count.should == 1

        page.revert_to! revision

        revision.attributes.except('page_revision_id','ordinal','notes','is_minor','is_published','author_id','created_at','updated_at', 'head_tags_attributes', 'page_id').should include(page.attributes.reject! { |key| PageRevision.ignored_page_attributes.include? key })
        revision.head_tags_attributes.should == {}
        page.head_tags.should == []
      end
    end

    describe '#forbid_changing_path' do
      context 'created_record' do
        it 'does not allow a path to be changed' do
          page = create :page, path: '/test'
          page.path = '/different'
          expect { page.save! }.to raise_error

          page.reload
          page.path.should == '/test'
        end
      end

      context 'new_record' do
        it 'allows the path to be changed' do
          page = build :page, path: '/test'
          page.save!

          page.path.should == '/test'
        end
      end
    end

    describe '#head_tags_attributes=' do
      let(:head_tag) { create :head_tag }
      let(:head_tag2) { create :head_tag }
      let(:page) { create :page, head_tags: [head_tag, head_tag2] }

      it 'does nothing if no action required' do
        page.reload
        page.body = 'foobar'
        page.save

        page.head_tags_attributes=([{'id' => head_tag.id, 'content' => head_tag.content, 'page_id' => head_tag.page_id},
                                    {'id' => head_tag2.id, 'content' => head_tag2.content,'page_id' => head_tag2.page_id}])
        page.reload
        page.head_tags.should include(head_tag, head_tag2)
        page.head_tags.count.should == 2
      end

      it 'deletes head_tag if not included in head_tags' do
        page.head_tags = [head_tag]
        page.save

        page.head_tags_attributes=(['id' => head_tag.id, 'content' => head_tag.content, 'page_id' => head_tag.page_id])
        page.reload
        page.head_tags.should == [head_tag]
      end

      it 'deletes head_tags if last head_tags' do
        page.head_tags = []
        page.save

        page.head_tags_attributes=([])
        page.reload
        page.head_tags.should == []
      end
    end

    describe '::sitemappable' do
      let(:page) { create :page }
      let(:page_2) { create :page, :redirect }
      let(:page_3) { create :page, meta_tags: { 'robots' => 'noindex' } }

      it 'only returns pages with a status code of 200 and dont have a noindex tag' do 
        page_2.status_code.code.should == 301

        Landable::Page.sitemappable.should include(page)
        Landable::Page.sitemappable.should_not include(page_2, page_3)
      end
    end

    describe '::generate_sitemap' do
      it 'returns a sitemap' do
        page = create :page
        Landable::Page.generate_sitemap.should include("<loc>#{page.path}</loc>")
      end
    end
  end
end
