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
      expect(dir.path).to eq '/'
    end

    it 'lists immediate children' do
      stub_contents

      dir = Directory.listing '/'
      expect(dir.subdirectories.map(&:path)).to eq ['/aff', '/seo']
      expect(dir.pages.map(&:path)).to eq ['/quux']

      dir = Directory.listing '/aff'
      expect(dir.subdirectories.map(&:path)).to eq ['/aff/deeply']
      expect(dir.pages.map(&:path)).to eq ['/aff/bar', '/aff/deeply_nested']

      dir = Directory.listing '/seo'
      expect(dir.subdirectories).to be_empty
      expect(dir.pages.map(&:path)).to eq ['/seo/baz', '/seo/foo']

      dir = Directory.listing '/aff/deeply'
      expect(dir.subdirectories).to be_empty
      expect(dir.pages.map(&:path)).to eq ['/aff/deeply/nested']
    end
  end
end
