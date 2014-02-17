# Pages, page revisions, and themes are all renderable. Rendering potentially
# involves assets. Rather than having to query for each asset as it's
# discovered, this concern allows retrieval of all asset names for a given
# body (#asset_names), and commits the habtm relation on save (#save_assets!;
# allows us to say "this asset belongs to 3 pages"). #assets is overridden to
# ensure that the assets returned /always/ reflect assets present in the Liquid
# template.

require_dependency 'landable/liquid'

module Landable
  module HasAssets
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :assets, class_name: 'Landable::Asset', join_table: assets_join_table_name

      before_save :save_assets!

      def asset_names
        # sticking with what we know about liquid, rather than doing regex.
        # (though regex may be faster, should we need that optimization later.)
        @asset_names ||= begin
          template = ::Liquid::Template.parse(body)
          asset_names_for_node template.root
        end
      end

      def assets
        Landable::Asset.where(name: asset_names)
      end

      # {asset_name: asset}
      def assets_as_hash
        Hash[assets.map { |asset| [asset.name, asset] }]
      end

      # passthrough for body=; clears the asset_names cache in the process
      def body= body_val
        @asset_names = nil
        self[:body] = body_val
      end

      # this looks weird; I swear it works
      def save_assets!
        self.assets = self.assets
      end


      private

      def asset_names_for_node node, names = []
        # set up a recursing function to search for asset tags
        if node.is_a? Landable::Liquid::AssetTag
          names << node.asset_name unless names.include? node.asset_name
        end

        if node.respond_to? :nodelist and node.nodelist
          node.nodelist.each { |node| asset_names_for_node node, names }
        end

        names
      end

    end

    module ClassMethods
      def assets_join_table_name
        "#{Landable.configuration.schema_prefix}landable.#{self.name.underscore.split('/').last}_assets"
      end
    end

  end
end
