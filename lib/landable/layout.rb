# TODO: Custom resolver for db themes: http://blog.jgarciam.net/post/21098440864/database-stored-templates-on-ruby-on-rails
# TODO: Multiple extentions with tilt
# TODO: Allow converting db-backed Theme to file-backed Theme

module Landable
  class Layout
    def initialize(file)
      @file = file
    end

    def process
      return if @processed

      path = @file.dup
      self.class.paths.each { |p| path.sub!(p, '') }

      path.sub!(/^\//, '')

      @path, @extension = path.split('.html.', 2)

      @body = File.read(@file)

      @processed = true
    end

    def to_theme
      process unless @processed

      theme = Theme.where(file: @path).first_or_initialize
      theme.name          ||= @path.gsub('/', ' ').titlecase
      theme.extension       = @extension
      theme.description     = description if theme.description.blank? || theme.description =~ /^Defined in/
      theme.body            = @body
      theme.editable        = false
      theme.thumbnail_url ||= "http://placehold.it/300x200"

      theme.save!

      theme
    end

    def description
      "Defined in #@path.html.#@extension"
    end

    class << self
      def all
        files.map { |file| new(file) }
      end

      def files
        paths.map { |path| Dir[path + "/**/[^_]*.html.*"] }.flatten
      end

      def paths
        @paths ||= Dir[Rails.root.join('app/views/layouts').to_s]
      end
    end
  end
end
