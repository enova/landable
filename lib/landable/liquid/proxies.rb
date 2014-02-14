module Landable
  module Liquid

    class CategoryProxy
      attr_accessor :categories

      def self.categories
        @categories = Hash.new
        fetched_categories = ::Landable::Category.all
        fetched_categories.each do |category|
          @categories[category.name.downcase] = {
            "pages" => category.pages,
            "name" => category.name
          }
        end
        @categories
      end
    end

  end
end
