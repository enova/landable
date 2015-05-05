require_dependency 'landable/has_assets'

module Landable
  class Theme < ActiveRecord::Base
    include Landable::TableName
    include Landable::HasAssets
    include Landable::Librarian

    validates_presence_of :name, :description
    validates_uniqueness_of :name, case_sensitive: false

    has_many :pages, inverse_of: :theme

    class << self
      def create_from_layouts!
        return unless table_exists?
        Layout.all.map(&:to_theme)
      end

      def most_used_on_pages
        order('pages_count DESC').first
      end
    end
  end
end
