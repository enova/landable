module Landable
  class Template < ActiveRecord::Base
    include Landable::TableName

    validates_presence_of   :name, :slug, :description
    validates_uniqueness_of :name, case_sensitive: false
    validates_uniqueness_of :slug, case_sensitive: false

    def name= val
      self[:name] = val
      self[:slug] ||= (val && val.underscore.gsub(/[^\w_]/, '_').gsub(/_{2,}/, '_'))
    end

    def partial?
      file.present?
    end

    class << self
      def create_from_partials!
        Partial.all.map(&:to_template)
      end
    end
  end
end
