module Landable
  module Traffic
    class MimeType < ActiveRecord::Base
      include Landable::TableName

      lookup_by :mime_type, cache: 50, find_or_create: true

      has_many :page_views
    end
  end
end
