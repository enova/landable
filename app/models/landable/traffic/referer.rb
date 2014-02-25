module Landable
  module Traffic
    class Referer < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_for :domain,       class_name: Domain
      lookup_for :path,         class_name: Path
      lookup_for :query_string, class_name: QueryString
    end
  end
end
