module Landable
  class StatusCodeCategory < ActiveRecord::Base
    self.table_name = 'landable.status_code_categories'
    has_many :status_codes, inverse_of: :status_code_category
  end
end
