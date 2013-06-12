module Landable
  class Theme < ActiveRecord::Base
    self.table_name = 'landable.themes'
    validates_presence_of :name, :description
    validates_uniqueness_of :name
    has_many :pages, inverse_of: :theme
  end
end
