module Landable
  class PageRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal
    # attributes :page_path # FIXME apparently trying to build an actual url, breaking
    attributes :page_theme_name
    attributes :page_title, :page_body
    attributes :page_status_code, :page_redirect_url
    attributes :page_meta_tags
    attributes :created_at

    has_one :page, embed: :id
    has_one :author, embed: :id
  end
end
