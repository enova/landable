module Landable
  module Traffic
    class Access < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_for :path, class_name: Path

      belongs_to :visitor
    end
  end
end
