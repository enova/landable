module Landable
  module Tracking
    class SearchTerm < ActiveRecord::Base
      self.table_name = 'traffic.search_terms'

      lookup_by :search_term, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
