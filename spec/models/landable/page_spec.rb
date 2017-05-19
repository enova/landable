require 'spec_helper'

module Landable
  describe Page do
    it { is_expected.to be_a HasAssets }
    it { is_expected.not_to have_valid(:status_code).when(nil, '') }
    it { is_expected.to have_valid(:status_code).when(200, 301, 302, 410) }
    it { is_expected.not_to have_valid(:status_code).when(201, 303, 405, 500, 404) }

    it { is_expected.to have_valid(:page_name).when(nil, 'Hello', 'adssad', '212131') }
    it { is_expected.not_to have_valid(:page_name).when("#{'hello' * 100}") }

    # config.reserved_paths = %w(/reserved_path_set_in_initializer /reject/.* /admin.*)
    context 'PathValidator' do
      it { is_expected.not_to have_valid(:path).when(nil, '', '/reserved_path_set_in_initializer') }
      it { is_expected.not_to have_valid(:path).when('/reject/this', '/admin', '/ADMIN', '/admin_something' '/admin/path') }
      it { is_expected.to have_valid(:path).when('/reserved_path_set_in_initializer_not', '/do/not/reject/path', '/', '/rejectwhatever', '/reject') }
    end

    it 'should set is_publishable to true on before_save' do
      page = FactoryGirl.build :page, is_publishable: false
      page.save!
      expect(page.is_publishable).to eq true
    end

    specify '#redirect?' do
      expect(Page.new).not_to be_redirect
      expect(Page.new).not_to be_redirect
      expect(Page.new(status_code: 200)).not_to be_redirect
      expect(Page.new(status_code: 410)).not_to be_redirect

      expect(Page.new(status_code: 301)).to be_redirect
      expect(Page.new(status_code: 302)).to be_redirect
    end

    describe '#published?' do
      context 'when published' do
        it 'should be true' do
          page = create :page
          page.publish! author: create(:author), notes: 'yo'
          expect(page).to be_published
        end
      end

      context 'when not published' do
        it 'should be false' do
          page = create :page
          expect(page).not_to be_published
        end
      end
    end

    specify '#path_extension' do
      expect(Page.new(path: 'foo').path_extension).to be_nil
      expect(Page.new(path: 'foo.bar').path_extension).to eq 'bar'
      expect(Page.new(path: 'foo.bar.baz').path_extension).to eq 'baz'
      expect(Page.new(path: 'foo.bar-baz').path_extension).to be_nil
    end

    describe '#content_type' do
      def content_type_for(path)
        Page.new(path: path).content_type
      end

      it 'should be text/html for html pages' do
        expect(content_type_for('asdf')).to eq 'text/html'
        expect(content_type_for('asdf.htm')).to eq 'text/html'
        expect(content_type_for('asdf.html')).to eq 'text/html'
      end

      it 'should be application/json for json' do
        expect(content_type_for('asdf.json')).to eq 'application/json'
      end

      it 'should be application/xml for xml' do
        expect(content_type_for('asdf.xml')).to eq 'application/xml'
      end

      it 'should be text/plain for everything else' do
        expect(content_type_for('foo.bar')).to eq 'text/plain'
        expect(content_type_for('foo.txt')).to eq 'text/plain'
      end
    end

    describe '#html?' do
      let(:page) { build :page }

      it 'should be true if content_type is text/html' do
        expect(page).to receive(:content_type) { 'text/html' }
        expect(page).to be_html
      end

      it 'should be false if content_type is not text/html' do
        expect(page).to receive(:content_type) { 'text/plain' }
        expect(page).not_to be_html
      end
    end

    describe '#redirect_url' do
      it 'is required if redirect?' do
        page = Page.new status_code: 301
        expect(page).not_to have_valid(:redirect_url).when(nil, '')
        expect(page).to have_valid(:redirect_url).when('http://example.com', 'http://www.somepath.com')
      end

      it 'not required for 200, 410' do
        page = Page.new
        expect(page).to have_valid(:redirect_url).when(nil, '')
      end
    end

    describe '#meta_tags' do
      it { expect(subject).to have_valid(:meta_tags).when(nil) }

      specify 'quacks like a Hash' do
        # Note the change from symbol to string; thus, always favor strings.
        page = create :page, meta_tags: { keywords: 'foo' }

        # rails 4.0 preserves the symbol for this instance; rails 4.1 switches straight to strings
        expect(page.meta_tags.keys.map(&:to_s)).to eq ['keywords']

        tags = Page.first.meta_tags
        expect(tags).to be_a(Enumerable)
        expect(tags.keys).to eq ['keywords']
        expect(tags.values).to eq ['foo']
      end
    end

    describe '#head_content' do
      it { expect(subject).to have_valid(:meta_tags).when(nil) }

      it 'works as a basic text area' do
        page = create :page, head_content: "<head en='en'/>"
        expect(page.head_content).to eq "<head en='en'/>"

        page.head_content = "<head en='magic'/>"
        page.save

        expect(page.head_content).to eq "<head en='magic'/>"
      end
    end

    describe '#path=' do
      it 'ensures a leading "/" on path' do
        expect(Page.new(path: 'foo/bar').path).to eq '/foo/bar'
      end

      it 'leaves nil and empty paths alone' do
        expect(Page.new(path: '').path).to eq ''
        expect(Page.new(path: nil).path).to be_nil
      end
    end

    describe '#publish' do
      let(:page) { FactoryGirl.create :page }
      let(:author) { FactoryGirl.create :author }

      it 'should create a page_revision' do
        expect { page.publish!(author: author) }.to change { page.revisions.count }.from(0).to(1)
      end

      it 'should have the provided author' do
        page.publish! author: author
        revision = page.revisions.last

        expect(revision.author).to eq author
      end

      it 'should update the published_revision_id' do
        page.publish! author: author
        revision = page.revisions.last

        expect(page.published_revision).to eq revision
      end

      it 'should set is_publishable to false' do
        page.is_publishable = true
        page.publish! author: author
        expect(page.is_publishable).to eq false
      end

      it 'should unset previous revision.is_published' do
        page.publish! author: author
        revision1 = page.published_revision
        page.publish! author: author
        expect(revision1.is_published).to eq false
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

        expect(page.published_revision.id).not_to eq revision.id
      end

      it 'should copy revision attributes into the page model' do
        page.title = 'Bar'
        page.publish! author: author

        revision = page.published_revision

        page.title = 'Foo'
        page.save!
        page.publish! author: author

        # ensure assignment for all copied attributes
        keys = %w(title path body category_id theme_id status_code meta_tags redirect_url)
        keys.each do |key|
          expect(page).to receive("#{key}=").with(revision.send(key))
        end

        page.revert_to! revision
      end
    end

    describe '#forbid_changing_path' do
      context 'created_record' do
        it 'does not allow a path to be changed' do
          page = create :page, path: '/test'
          page.path = '/different'
          expect { page.save! }.to raise_error

          page.reload
          expect(page.path).to eq '/test'
        end
      end

      context 'new_record' do
        it 'allows the path to be changed' do
          page = build :page, path: '/test'
          page.save!

          expect(page.path).to eq '/test'
        end
      end
    end

    describe '#preview_path' do
      it 'should return the preview path' do
        page = build :page
        expect(page).to receive(:public_preview_page_path) { 'foo' }
        expect(page.preview_path).to eq 'foo'
      end
    end

    describe '#preview_url' do
      it 'should return the preview url' do
        page = build :page
        expect(page).to receive(:public_preview_page_url) { 'foo' }
        expect(page.preview_url).to eq 'foo'
      end
    end

    describe '::sitemappable' do
      let(:page) do
        create :page do |page|
          page.publish! author: create(:author), notes: 'yo'
        end
      end
      let(:page_2) { create :page, :redirect }
      let(:page_3) { create :page, meta_tags: { 'robots' => 'noindex' } }
      let(:page_4) { create :page }

      it 'only returns published pages with a status code of 200 and dont have a noindex tag' do
        expect(page_2.status_code).to eq 301

        expect(Landable::Page.sitemappable).to include(page)
        expect(Landable::Page.sitemappable).not_to include(page_2, page_3, page_4)
      end
    end

    describe '#downcase_path' do
      it 'should force a path to be lowercase' do
        page = build :page, path: '/SEO'
        expect(page).to be_valid
        expect(page.path).to eq '/seo'
      end

      it 'doesnt change a downcase path' do
        page = build :page, path: '/seo'
        expect(page).to be_valid
        expect(page.path).to eq '/seo'
      end
    end

    describe '#redirect_url' do
      context 'validater' do
        before(:each) { @page = build :page, path: '/' }

        it 'should correctly validate http://' do
          @page.redirect_url = 'http://www.google.com'
          expect(@page).to be_valid
        end

        it 'should correctly validate https://' do
          @page.redirect_url = 'http://www.google.com'
          expect(@page).to be_valid
        end

        it 'should correctly validate /' do
          @page.redirect_url = '/some/uri'
          expect(@page).to be_valid
        end

        it 'should not validate www' do
          @page.redirect_url = 'www.google.com'
          expect(@page).not_to be_valid
        end

        it 'should not validate bad urls' do
          @page.redirect_url = 'hdasdfpou'
          expect(@page).not_to be_valid
        end
      end
    end

    describe '::generate_sitemap' do
      it 'returns a sitemap' do
        page = create :page
        page.publish! author: create(:author), notes: 'yo'

        expect(Landable::Page.generate_sitemap(host: 'example.com',
                                        protocol: 'http',
                                        exclude_categories: [],
                                        sitemap_additional_paths: [])).to include("<loc>http://example.com#{page.path}</loc>")
      end

      it 'does not include excluded categories' do
        cat = create :category, name: 'Testing'
        page = create :page, category: cat
        expect(Landable::Page.generate_sitemap(host: 'example.com',
                                        protocol: 'http',
                                        exclude_categories: ['Testing'],
                                        sitemap_additional_paths: [])).not_to include("<loc>http://example.com#{page.path}</loc>")
      end

      it 'can handle https protocol' do
        page = create :page
        page.publish! author: create(:author), notes: 'yo'

        expect(Landable::Page.generate_sitemap(host: 'example.com',
                                        protocol: 'https',
                                        exclude_categories: [],
                                        sitemap_additional_paths: [])).to include("<loc>https://example.com#{page.path}</loc>")
      end

      it 'can handle additional pages' do
        expect(Landable::Page.generate_sitemap(host: 'example.com',
                                        protocol: 'https',
                                        exclude_categories: [],
                                        sitemap_additional_paths: ['/terms.html'])).to include('<loc>https://example.com/terms.html</loc>')
      end
    end

    describe '::by_path' do
      it 'returns first page with path name' do
        page = create :page, path: '/seo'
        expect(Landable::Page.by_path('/seo')).to eq page
      end
    end

    describe 'validate#body_strip_search' do
      it 'raises errors if errors!' do
        page = build :page, path: '/'
        page.body = "{% image_tag 'bad_image' %}"
        expect(page).not_to be_valid
        expect(page.errors[:body]).not_to be_empty
      end

      it 'does not raise error when no syntax error' do
        page = build :page, path: '/'
        page.body = 'body'
        expect(page).to be_valid
        page.save!
        expect(page.body).to eq 'body'
      end
    end
  end
end
