module Landable
  class Partial
    def initialize(file)
      @file = file
    end

    def process
      @body = File.read(@file)

      @path = @file.split('/_', 2).last

      @name = @path.split('.ht', 2).first

      @processed = true
    end

    def description 
      "Defined in #{@path}"
    end

    def to_template
      process unless @processed

      template                 = Template.where(file: @path).first_or_initialize
      template.body            = @body
      template.name            = @name
      template.description     = description
      template.editable        = false
      template.is_layout       = false
      template.thumbnail_url ||= "http://placehold.it/300x200"

      template.save!

      template
    end

    class << self
      def all
        files.map { |file| new(file) }
      end

      def files
        files = []

        Landable.configuration.partials_to_templates.each do |path|
          files << Dir[Rails.root.join("**/#{path}").to_s]
        end

        files.flatten
      end
    end
  end
end