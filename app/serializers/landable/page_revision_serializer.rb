module Landable
  class PageRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal
    # attributes :page_path # FIXME apparently trying to build an actual url, breaking
    attributes :snapshot_attributes
    attributes :created_at

    has_one :page, embed: :id
    has_one :author, embed: :id
  end
end
