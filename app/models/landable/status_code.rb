module Landable
  class StatusCode < ActiveRecord::Base
    self.table_name = 'landable.status_codes'
    has_many :pages, inverse_of: :status_code
  end
end
