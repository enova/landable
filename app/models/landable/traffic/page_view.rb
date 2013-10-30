module Landable
  module Traffic
    class PageView < ActiveRecord::Base
      self.table_name = 'traffic.page_views'
      self.record_timestamps = false

      belongs_to :visit

      lookup_for :mime_type,    class_name: MimeType
      lookup_for :http_method,  class_name: HTTPMethod
      lookup_for :path,         class_name: Path
      lookup_for :query_string, class_name: QueryString
    end
  end
end
