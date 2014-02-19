module Landable
  class Category < ActiveRecord::Base
    include Landable::TableName
    
    has_many :pages
  end
end
