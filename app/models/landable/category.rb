module Landable
  class Category < ActiveRecord::Base
    self.table_name = "#{Landable.configuration.database_schema_prefix}landable.categories"
    has_many :pages
  end
end
