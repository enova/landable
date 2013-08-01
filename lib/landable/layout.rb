# TODO: Custom resolver for db themes: http://blog.jgarciam.net/post/21098440864/database-stored-templates-on-ruby-on-rails
# TODO: Multiple extentions with tilt

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

      if theme = Theme.where(file: @path.downcase).first
        theme.extension   = @extension
        theme.description = description if theme.description =~ /^Defined in/
        theme.body        = @body
        theme.editable    = false

        theme.save! if theme.changed?
      else
        theme = Theme.create(defaults)
      end

      theme
    end

    def description
      "Defined in #@path.html.#@extension"
    end

    def defaults
      {
        name: @path.gsub('/', ' ').titlecase,
        file: @path.downcase,
        body: File.read(@file),
        description: description,
        thumbnail_url: "http://placehold.it/300x200"
      }
    end

    class << self
      def all
        files.map { |file| new(file) }
      end

      def files
        paths.map { |path| Dir[path + "/**/[^_]*.html.*"] }.flatten
      end

      def paths
        @paths ||= Dir[*ActionController::Base.view_paths.map { |path| path.to_s + "/layouts" }]
      end
    end
  end
end
