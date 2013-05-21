module Landable
  class Directory
    include ActiveModel::SerializerSupport

    def self.listing(parent)
      pages   = Page.where('path LIKE ?', "#{parent}%").to_a
      subdirs = pages.group_by { |page| page.directory_after(parent) }
      notdirs = subdirs.delete(nil) || []
      subdirs = subdirs.map { |name, contents| Directory.new("#{parent}/#{name}") }
      Directory.new(parent, subdirs.sort_by(&:path), notdirs.sort_by(&:path))
    end

    attr_reader :path, :directories, :pages

    def initialize(path, directories = [], pages = [])
      @path = path.squeeze '/'
      @directories = directories
      @pages = pages
    end

    def empty?
      @directories.empty? && @pages.empty?
    end
  end
end
