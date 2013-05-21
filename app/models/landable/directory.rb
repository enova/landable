module Landable
  class Directory
    def self.listing(parent)
      paths   = Path.where('path LIKE ?', "#{parent}%").to_a
      subdirs = paths.group_by { |path| path.directory_after(parent) }
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

    def as_json(opts = {})
      { path: path, directories: directories, pages: pages }
    end
  end
end
