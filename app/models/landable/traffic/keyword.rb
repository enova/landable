module Landable
  module Traffic
    class Keyword < ActiveRecord::Base
      self.table_name = 'traffic.keywords'

      lookup_by :keyword, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
