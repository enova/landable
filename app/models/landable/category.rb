module Landable
  class Category < ActiveRecord::Base
    self.table_name = 'landable.categories'
    has_many :pages
  end
end
