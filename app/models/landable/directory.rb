module Landable
  class Directory
    include ActiveModel::SerializerSupport

    def self.listing(parent)
      parent_with_slash = parent.gsub(%r{^(.*?)\/?$}, '\1/')
      pages   = Page.where('path LIKE ?', "#{parent_with_slash}%").to_a
      subdirs = pages.group_by { |page| page.directory_after(parent_with_slash) }
      notdirs = subdirs.delete(nil) || []
      subdirs = subdirs.map { |name, _contents| Directory.new("#{parent}/#{name}") }
      Directory.new(parent, subdirs.sort_by(&:path), notdirs.sort_by(&:path))
    end

    attr_reader :path, :subdirectories, :pages
    alias_attribute :id, :path

    def initialize(path, subdirectories = [], pages = [])
      @path = path.squeeze '/'
      @subdirectories = subdirectories
      @pages = pages
    end
  end
end
