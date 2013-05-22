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

    attr_reader :path, :subdirectories, :pages

    def initialize(path, subdirectories = [], pages = [])
      @path = path.squeeze '/'
      @subdirectories = subdirectories
      @pages = pages
    end

    def empty?
      @subdirectories.empty? && @pages.empty?
    end
  end
end
