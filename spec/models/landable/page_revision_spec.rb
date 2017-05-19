require 'spec_helper'

module Landable
  describe PageRevision do
    let(:author) { create(:author) }
    let(:asset)  { create(:asset)  }

    let(:page) do
      create(:page, path: '/test/path', title: 'title', status_code: 200,
                    body: 'body', redirect_url: 'http://www.redirect.com/here',
                    meta_tags: { 'key' => 'value' }, head_content: 'head_content')
    end

    let(:revision) do
      PageRevision.new page_id: page.id, author_id: author.id
    end

    it { is_expected.to be_a HasAssets }

    it 'defaults to is_published = true' do
      expect(PageRevision.new.is_published).to eq true
    end

    describe '#page_id=' do
      it 'should set page revision attributes matching the page' do
        attrs = revision.attributes.except('page_revision_id', 'ordinal', 'notes', 'is_minor', 'is_published', 'author_id', 'created_at', 'updated_at', 'page_id', 'audit_flags')
        expect(attrs).to include(page.attributes.except(*PageRevision.ignored_page_attributes))
      end
    end

    describe '#snapshot' do
      it 'should build a page based on the cached page attributes' do
        snapshot = revision.snapshot
        expect(snapshot).to be_new_record
        expect(snapshot).to be_an_instance_of Page
        expect(snapshot.title).to eq page.title
        expect(snapshot.path).to eq page.path
        expect(snapshot.head_content).to eq page.head_content
        expect(snapshot.meta_tags).to eq page.meta_tags
        expect(snapshot.body).to eq page.body
        expect(snapshot.redirect_url).to eq page.redirect_url
        expect(snapshot.category_id).to eq page.category_id
        expect(snapshot.theme_id).to eq page.theme_id
        expect(snapshot.status_code).to eq page.status_code
      end
    end

    describe '#is_published' do
      it 'should set is_published to true and false as requested' do
        revision = PageRevision.new
        revision.page_id = page.id
        revision.author_id = author.id
        revision.unpublish!
        expect(revision.is_published).to eq false
        revision.publish!
        expect(revision.is_published).to eq true
      end
    end

    describe '#republish!' do
      it 'republishes a page revision with almost exact attrs' do
        template = create :template, name: 'Basic'
        old = PageRevision.create!(page_id: page.id, author_id: author.id, is_published: true)
        new_author = create :author
        old.republish!(author_id: new_author.id, notes: 'Great Note', template: template.name)

        new_record = PageRevision.order('created_at ASC').last
        expect(new_record.author_id).to eq new_author.id
        expect(new_record.notes).to eq "Publishing update for template #{template.name}: Great Note"
        expect(new_record.page_id).to eq page.id
        expect(new_record.body).to eq page.body
      end
    end

    describe '#preview_path' do
      it 'should return the preview path' do
        expect(revision).to receive(:public_preview_page_revision_path) { 'foo' }
        expect(revision.preview_path).to eq 'foo'
      end
    end

    describe '#preview_url' do
      it 'should return the preview url' do
        allow(Landable.configuration).to receive(:public_host) { 'foo' }
        expect(revision).to receive(:public_preview_page_revision_url).with(revision, host: 'foo') { 'bar' }
        expect(revision.preview_url).to eq 'bar'
      end
    end

    describe '#add_screenshot!' do
      let(:screenshots_enabled) { true }

      before(:each) do
        allow(Landable.configuration).to receive(:screenshots_enabled) { screenshots_enabled }
      end

      it 'should be fired before create' do
        expect(revision).to receive :add_screenshot!
        revision.save!
      end

      it 'should add a screenshot' do
        screenshot = double('screenshot')

        allow(revision).to receive(:preview_url) { 'http://google.com/foo' }
        expect(ScreenshotService).to receive(:capture).with(revision.preview_url) { screenshot }

        expect(revision).to receive(:screenshot=).with(screenshot).ordered
        expect(revision).to receive(:store_screenshot!).ordered
        expect(revision).to receive(:write_screenshot_identifier).ordered
        expect(revision).to receive(:update_column).with(:screenshot, revision[:screenshot]).ordered

        revision.add_screenshot!
      end

      context 'screenshots disabled' do
        let(:screenshots_enabled) { false }

        it 'should skip' do
          expect(revision).to receive(:add_screenshot!).and_call_original
          expect(ScreenshotService).not_to receive :capture
          expect(revision).not_to receive :screenshot=

          revision.save!
        end
      end
    end

    describe '#screenshot_url' do
      context 'with screenshot' do
        it 'should return the screenshot url' do
          screenshot = double('screenshot', url: 'foobar')

          allow(revision).to receive(:screenshot) { screenshot }
          expect(revision.screenshot_url).to eq screenshot.url
        end
      end

      context 'without screenshot' do
        it 'should return nil' do
          allow(revision).to receive(:screenshot) { nil }
          expect(revision.screenshot_url).to be_nil
        end
      end
    end
  end
end
