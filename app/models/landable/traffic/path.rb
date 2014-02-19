module Landable
  module Traffic
    class Path < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :path, cache: 50, find_or_create: true

      has_many :accesses
      has_many :page_views
      has_many :referers
    end
  end
end
