module Landable
  class Layout < ActiveRecord::Base
    self.table_name = 'landable.layouts'

    validates_presence_of   :name, :description
    validates_uniqueness_of :name, case_sensitive: false
  end
end
