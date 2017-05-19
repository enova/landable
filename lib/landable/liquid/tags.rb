require 'action_view'

module Landable
  module Liquid
    class Tag < ::Liquid::Tag
      include ActionView::Helpers::TagHelper

      protected

      def lookup_page(context)
        context.registers.fetch(:page) do
          fail(ArgumentError, "`page' value was never registered with the template")
        end
      end
    end

    class TitleTag < Tag
      def render(context)
        page = lookup_page context
        content_tag(:title, page.title)
      end
    end

    class MetaTag < Tag
      def render(context)
        page = lookup_page context
        tags = page.meta_tags || {}

        tags.map do |name, value|
          tag(:meta, content: value, name: name)
        end.join("\n")
      end
    end

    class HeadContent < Tag
      def render(context)
        page = lookup_page context

        page.head_content
      end
    end

    class Head < Tag
      def render(context)
        lookup_page context

        head = []

        %w(title_tag meta_tags head_content).each do |tag_name|
          tag = "Landable::Liquid::#{tag_name.classify}".safe_constantize.new(tag_name, nil, nil)
          head << tag.render(context) if tag.render(context).present?
        end

        head.join("\n")
      end
    end

    class Body < Tag
      def render(context)
        context.environments.first.fetch('body')
      end
    end

    class TemplateTag < Tag
      attr_accessor :template_slug

      def initialize(_tag, param, _tokens)
        param_tokens = param.split(/\s+/)
        @template_slug = param_tokens.shift
        @variables = Hash[param_tokens.join(' ').scan(/([\w_]+):\s+"([^"]*)"/)]
      end

      def render(context)
        template = Landable::Template.find_by_slug @template_slug

        # Handle Templates that are deleted (don't render anything)
        return if template && template.deleted_at?

        # Handle Templates that are Partials
        if template && template.partial?
          responder = context.registers[:responder]
          # the controller we need for rendering. the request we need to dodge a bug in rails 4.1
          # (fixed in https://github.com/rails/rails/commit/f6d9b689977c1dca1ed7f149f704d1b4344cd691).
          # if we need to render pages offline (i.e. without a request) we'll need to rethink this.
          if responder.try(:controller).try(:request).present?
            responder.controller.render_to_string(partial: template.file)
          else
            "<!-- render error: unable to render \"#{@template_slug}\", no controller/responder present -->"
          end

        # Handle Published Templates
        elsif template && template.revisions.where(is_published: true).present?
          template = template.revisions.where(is_published: true).first
          ::Liquid::Template.parse(template.body).render @variables

        # Handle Template Errors
        else
          "<!-- render error: missing published template \"#{@template_slug}\" -->"
        end
      end
    end
  end
end
