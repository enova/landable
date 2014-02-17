module Landable
  module Traffic
    class Keyword < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.keywords"

      lookup_by :keyword, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
