# Drops are for lazy-loading content.
#  - http://www.rubydoc.info/github/Shopify/liquid/Liquid/Drop
#  - https://github.com/Shopify/liquid/blob/master/lib/liquid/drop.rb

module Landable
  module Liquid

    # CategoryProxy gives us these:
    #
    # {{ categories.size }}
    #
    # {% for category in categories %}
    #   {{ category.name }}: {{ category.pages.size }} pages
    # {% endfor %}
    #
    # <h1>Blog posts</h1>
    # <ul>
    #   {% for page in categories.blog.pages %}
    #     <li><a href="{{ page.url }}">{{ page.name }}</a></li>
    #   {% endfor %}
    # </ul>
    class CategoryProxy < ::Liquid::Drop

      def before_method method_name
        category_cache[method_name] ||= ::Landable::Category.find_by_slug method_name
      end

      def size
        @size ||= Category.count
      end

      def each &block
        ::Landable::Category.all.each &block
      end


      protected

      def category_cache
        @category_cache ||= {}
      end

    end

  end
end
