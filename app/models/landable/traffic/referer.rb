module Landable
  module Traffic
    class Referer < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.referers"

      lookup_for :domain,       class_name: Domain
      lookup_for :path,         class_name: Path
      lookup_for :query_string, class_name: QueryString
    end
  end
end
