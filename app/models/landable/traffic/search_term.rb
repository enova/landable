module Landable
  module Traffic
    class SearchTerm < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.database_schema_prefix}landable_traffic.search_terms"

      lookup_by :search_term, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
