module Landable
  class Category < ActiveRecord::Base
    include Landable::TableName

    has_many :pages

    validates_uniqueness_of :name, case_sensitive: false
    validates_uniqueness_of :slug

    before_validation :set_slug

    def to_liquid
      {
        'name' => name,
        'pages' => pages.published.to_a
      }
    end

    protected

    def set_slug
      self.slug = name.downcase.gsub(/[^\w]/, '_').gsub(/_{2,}/, '_')
    end
  end
end
