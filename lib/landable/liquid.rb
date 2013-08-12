require 'liquid'

module Landable
  module Liquid
    class Tag < ::Liquid::Tag
      include ActionView::Helpers::TagHelper

      protected

      def lookup_page(context)
        context.registers.fetch(:page) do
          raise ArgumentError.new("`page' value was never registered with the template")
        end
      end
    end

    class AssetTag < Tag
      attr_accessor :asset_name

      protected

      def lookup_asset(context, name)
        assets = context.registers.fetch(:assets) do
          raise ArgumentError.new("`assets' value was never registered with the template")
        end

        assets.fetch(name) do
          raise ArgumentError.new("No `#{name}' asset available in #{assets.inspect}")
        end
      end
    end

    class Title < Tag
      def render(context)
        page = lookup_page context
        content_tag(:title, page.title)
      end
    end

    class MetaTags < Tag
      def render(context)
        page = lookup_page context
        tags = page.meta_tags || {}

        tags.map { |name, value|
          tag(:meta, name: name, content: value)
        }.join("\n")
      end
    end

    class Img < AssetTag
      def initialize(name, param, tokens)
        @asset_name = param.strip
      end

      def render(context)
        asset = lookup_asset context, asset_name
        tag :img, src: asset.public_url, alt: asset.description
      end
    end

    class AssetAttribute < AssetTag
      def initialize(tag, param, tokens)
        @attribute  = tag.sub /^asset_/, ''
        @asset_name = param.strip
      end

      def render(context)
        asset = lookup_asset context, asset_name

        case @attribute
        when 'url' then asset.public_url
        else asset.send @attribute
        end
      end
    end

    class Template < ::Liquid::Tag
      def initialize(tag, param, tokens)
        param_tokens = param.split(/\s+/)
        @template_slug = param_tokens.shift
        @variables = Hash[param_tokens.join(' ').scan(/([\w_]+):\s+"([^"]*)"/)]
      end

      def render(context)
        template = Landable::Template.find_by_slug @template_slug

        if template
          ::Liquid::Template.parse(template.body).render @variables
        else
          "<!-- render error: missing template \"#{@template_slug}\" -->"
        end
      end
    end

    module DefaultFilter
      def default(input, default_output=nil)
        input.presence ? input : default_output
      end
    end
  end

  # Tag generators
  ::Liquid::Template.register_tag('title_tag', Landable::Liquid::Title)
  ::Liquid::Template.register_tag('meta_tags', Landable::Liquid::MetaTags)
  ::Liquid::Template.register_tag('img_tag',   Landable::Liquid::Img)

  # Only called tags so we can use a function-like syntax
  ::Liquid::Template.register_tag('asset_url', Landable::Liquid::AssetAttribute)
  ::Liquid::Template.register_tag('asset_description', Landable::Liquid::AssetAttribute)

  # Template references
  ::Liquid::Template.register_tag('template', Landable::Liquid::Template)

  # Helpers
  ::Liquid::Template.register_filter(Landable::Liquid::DefaultFilter)
end
