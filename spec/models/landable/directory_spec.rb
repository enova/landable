require 'spec_helper'

module Landable
  describe Directory, '.listing' do
    def stub_contents
      ['/seo/foo', '/aff/bar', '/seo/baz', '/aff/deeply/nested', '/aff/deeply_nested', '/quux'].each do |path|
        create :page, path: path
      end
    end

    it 'knows its own path' do
      dir = Directory.listing '/'
      dir.path.should == '/'
    end

    it 'lists immediate children' do
      stub_contents

      dir = Directory.listing '/'
      dir.subdirectories.map(&:path).should == ['/aff', '/seo']
      dir.pages.map(&:path).should == ['/quux']

      dir = Directory.listing '/aff'
      dir.subdirectories.map(&:path).should == ['/aff/deeply']
      dir.pages.map(&:path).should == ['/aff/bar', '/aff/deeply_nested']

      dir = Directory.listing '/seo'
      dir.subdirectories.should be_empty
      dir.pages.map(&:path).should == ['/seo/baz', '/seo/foo']

      dir = Directory.listing '/aff/deeply'
      dir.subdirectories.should be_empty
      dir.pages.map(&:path).should == ['/aff/deeply/nested']
    end
  end
end
