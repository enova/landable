module Landable
  class PageDecorator
    include ActionView::Helpers::TagHelper

    def initialize(page)
      fail(TypeError, 'Use Landable::NullPageDecorator') if page.nil?
      @page = page
    end

    def title
      content_tag('title', page.title) if page.title?
    end

    def path
      page.path
    end

    def page_name
      page.page_name
    end

    def body
      page.body.try(:html_safe)
    end

    def head_content
      page.head_content.try(:html_safe)
    end

    def meta_tags
      return nil unless page.meta_tags?

      page.meta_tags.map do |name, value|
        tag('meta', name: name, content: value) if value.present?
      end.compact.join("\n").html_safe
    end

    private

    attr_reader :page # Keeping it private until there's a compelling reason not to
  end
end
