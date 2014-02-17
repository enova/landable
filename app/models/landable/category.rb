module Landable
  class Category < ActiveRecord::Base
    self.table_name = "#{Landable.configuration.schema_prefix}landable.categories"
    has_many :pages
  end
end
