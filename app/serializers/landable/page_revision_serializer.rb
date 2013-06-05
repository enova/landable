module Landable
  class PageRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal
    attributes :page_id, :author_id
    attributes :page_path, :page_theme_name
    attributes :page_title, :page_body
    attributes :page_status_code, :page_redirect_url
    attributes :page_meta_tags

    has_one :page, embed: :id
    has_one :author, embed: :id
  end
end
