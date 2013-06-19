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

      def lookup_asset(context, name)
        assets = context.registers.fetch(:assets) do
          raise ArgumentError.new("`assets' value was never registered with the template")
        end

        assets.fetch(name) do
          raise ArgumentError.new("No `#{name}' asset available")
        end
      end

      def asset_uri(context, asset)
        uri = URI.parse(context.registers[:asset_prefix] || 'http://example.com/')
        uri.path += asset.basename
        uri.to_s
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

    class Img < Tag
      def initialize(name, param, tokens)
        @asset_name = param.strip
      end

      def render(context)
        asset = lookup_asset context, @asset_name
        tag :img, src: asset_uri(context, asset), alt: asset.description
      end
    end

    class AssetAttribute < Tag
      def initialize(tag, param, tokens)
        @attribute  = tag.sub /^asset_/, ''
        @asset_name = param.strip
      end

      def render(context)
        asset = lookup_asset context, @asset_name

        case @attribute
        when 'url' then asset_uri(context, asset)
        else asset.send @attribute
        end
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
end
