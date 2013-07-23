module Landable
  class StatusCode < ActiveRecord::Base
    self.table_name = 'landable.status_codes'
    has_many :pages, inverse_of: :status_code
    belongs_to :status_code_category, class_name: 'Landable::StatusCodeCategory'

    def is_redirect?
      status_code_category.name == 'redirect'
    end

    def is_missing?
      status_code_category.name == 'missing'
    end

    def is_okay?
      status_code_category.name == 'okay'
    end
  end
end
