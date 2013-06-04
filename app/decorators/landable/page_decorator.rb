module Landable
  class PageDecorator
    include ActionView::Helpers::TagHelper

    def initialize(page)
      raise TypeError.new("Use Landable::NullPageDecorator") if page.nil?
      @page = page
    end

    def head
      (title + meta_tags).html_safe
    end

    def title
      title = page.title || default_title
      content_tag('title', title)
    end

    def meta_tags
      return unless tags = page.meta_tags
      return if tags.empty?

      tags.map { |name, value|
        tag('meta', name: name, value: value) if value.present?
      }.compact.join("\n").html_safe
    end

    private

    attr_reader :page # Keeping it private until there's a compelling reason not to

    def default_title
      if page.theme
        "'#{page.theme.name}' theme; default title"
      else
        "unthemed; default title"
      end
    end
  end
end
