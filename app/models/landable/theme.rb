module Landable
  class Theme < ActiveRecord::Base
    self.table_name = 'landable.themes'

    validates_presence_of   :name, :description
    validates_uniqueness_of :name, case_sensitive: false

    has_many :pages, inverse_of: :theme
    has_many :theme_assets
    has_many :assets, through: :theme_assets
  end
end
