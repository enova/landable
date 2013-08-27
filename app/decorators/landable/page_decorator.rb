module Landable
  class PageDecorator
    include ActionView::Helpers::TagHelper

    def initialize(page)
      raise TypeError.new("Use Landable::NullPageDecorator") if page.nil?
      @page = page
    end

    def title
      content_tag('title', title) if page.title?
    end

    def path
      page.path
    end

    def body
      page.body
    end

    def head_tags
      return if page.head_tags.empty?

      page.head_tags.map(&:content).join("\n").html_safe
    end

    def meta_tags
      return unless tags = page.meta_tags
      return if tags.empty?

      tags.map { |name, value|
        tag('meta', name: name, content: value) if value.present?
      }.compact.join("\n").html_safe
    end

    private

    attr_reader :page # Keeping it private until there's a compelling reason not to
  end
end
