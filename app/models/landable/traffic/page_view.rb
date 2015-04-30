module Landable
  module Traffic
    class PageView < ActiveRecord::Base
      include Landable::TableName
      self.record_timestamps = false

      belongs_to :visit

      lookup_for :mime_type,    class_name: MimeType
      lookup_for :http_method,  class_name: HTTPMethod
      lookup_for :path,         class_name: Path
      lookup_for :query_string, class_name: QueryString

      before_create :set_page_revision

      protected

      def set_page_revision
        page = Landable::Page.find_by(path: path)
        self.page_revision_id = page.try(:published_revision_id)
      end
    end
  end
end
