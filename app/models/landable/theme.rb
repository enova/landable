require_dependency 'landable/has_assets'

module Landable
  class Theme < ActiveRecord::Base
    include Landable::HasAssets

    self.table_name = 'landable.themes'

    validates_presence_of   :name, :description
    validates_uniqueness_of :name, case_sensitive: false

    has_many :pages, inverse_of: :theme
  end
end
