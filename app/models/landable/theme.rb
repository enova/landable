module Landable
  class Theme < ActiveRecord::Base
    self.table_name = 'landable.themes'

    before_validation :downcase_name

    validates_presence_of :name, :description
    validates_uniqueness_of :name
    has_many :pages, inverse_of: :theme

    def downcase_name
      self.name = name.downcase
    end
  end
end
