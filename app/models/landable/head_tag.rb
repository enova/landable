module Landable
  class HeadTag < ActiveRecord::Base
    self.table_name = 'landable.head_tags'

    validates_presence_of  :content

    belongs_to :page, class_name: 'Landable::Page'
  end
end
