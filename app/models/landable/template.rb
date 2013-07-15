module Landable
  class Template < ActiveRecord::Base
    self.table_name = 'landable.templates'

    validates_presence_of   :name, :description
    validates_uniqueness_of :name, case_sensitive: false
  end
end
