require_dependency 'landable/liquid'

module Landable
  module HasTemplates
    extend ActiveSupport::Concern

    included do
      has_and_belongs_to_many :templates, class_name: 'Landable::Template', join_table: templates_join_table_name

      before_save :save_templates!

      def template_names
        # sticking with what we know about liquid, rather than doing regex.
        # (though regex may be faster, should we need that optimization later.)
        @template_names ||= begin
          template = ::Liquid::Template.parse(body)
          template_names_for_node template.root
        end
      end

      def templates
        Landable::Template.where(slug: template_names)
      end

      # passthrough for body=; clears the template_names cache in the process
      def body= body_val
        @template_slug = nil
        @asset_names = nil
        self[:body] = body_val
      end

      # this looks weird; I swear it works
      def save_templates!
        self.templates = self.templates
      end

      private

      def template_names_for_node node, names = []
        # set up a recursing function to search for template tags
        if node.is_a? Landable::Liquid::TemplateTag
          names << node.template_slug unless names.include? node.template_slug
        end

        if node.respond_to? :nodelist and node.nodelist
          node.nodelist.each { |node| template_names_for_node node, names }
        end

        names
      end

    end

    module ClassMethods
      def templates_join_table_name
        "#{Landable.configuration.database_schema_prefix}landable.#{self.name.underscore.split('/').last}_templates"
      end
    end
  end
end
