require 'spec_helper'

module Landable
  describe Page do
    it { should_not have_valid(:path).when(nil, '') }
    it { should_not have_valid(:status_code).when(nil, '') }
    it { should have_valid(:status_code).when(200, 301, 302, 404) }
    it { should_not have_valid(:status_code).when(201, 303, 405, 500) }

    specify "#redirect?" do
      Page.new.should_not be_redirect
      Page.new(status_code: 200).should_not be_redirect
      Page.new(status_code: 404).should_not be_redirect

      Page.new(status_code: 301).should be_redirect
      Page.new(status_code: 302).should be_redirect
    end

    context '#redirect_url' do
      it 'is required if redirect?' do
        page = Page.new status_code: 301
        page.should_not have_valid(:redirect_url).when(nil, '')
        page.should have_valid(:redirect_url).when('http://example.com', '/some/path')
      end

      it 'not required for 200, 404' do
        page = Page.new status_code: 200
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

    describe '#theme=' do
      it 'sets theme_name' do
        Page.new(theme: 'foo').theme_name.should == 'foo'
      end

      it 'changes #theme object' do
        theme = double 'theme'
        Landable.stub! find_theme: theme # sorry world
        Page.new(theme: 'anything').theme.should == theme
      end
    end
  end
end
