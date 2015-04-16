require 'action_view'

module Landable
  module Liquid
    class AssetTag < ::Liquid::Tag
      attr_accessor :tag_name, :asset_name

      # we'll be calling up to methods in here
      include ActionView::Helpers::AssetTagHelper

      # included for asset digest support
      include Sprockets::Rails::Helper

      def initialize(tag_name, param, tokens)
        @tag_name = tag_name
        @asset_name = param.strip
        @tokens = tokens
      end

      def render(context)
        tag_method = tag_name.to_sym
        tag_method = :image_tag if tag_method == :img_tag

        # if this matches an application asset, use that
        if assets_environment[asset_name]
          send tag_method, asset_name

        # otherwise, find an asset of our own
        else
          asset = lookup_asset context, asset_name

          options = {}
          options[:alt] = asset.description if tag_method == :image_tag

          send tag_method, asset.public_url, options
        end
      end

      protected

      def lookup_asset(context, name)
        assets = context.registers.fetch(:assets) do
          fail(ArgumentError, "`assets' value was never registered with the template")
        end

        assets.fetch(name) do
          fail(ArgumentError, "No `#{name}' asset available in #{assets.inspect}")
        end
      end

      # stuff for sprockets
      delegate :assets_prefix, :digest_assets, to: 'ActionView::Base'

      # ActionView::Base.assets_environment will be nil if the pipeline is
      # disabled - use this instead
      def assets_environment
        Rails.application.assets
      end
    end

    class AssetAttributeTag < AssetTag
      def render(context)
        asset = lookup_asset context, asset_name
        attribute = tag_name.sub(/^asset_/, '')

        if attribute == 'url'
          asset.public_url
        else
          asset.send attribute
        end
      end
    end
  end
end
