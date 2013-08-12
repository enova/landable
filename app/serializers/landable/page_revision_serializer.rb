require_dependency 'landable/author_serializer'
require_dependency 'landable/theme'

module Landable
  class PageRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal, :notes, :is_minor, :is_published
    attributes :snapshot_attributes
    attributes :created_at, :updated_at
    attributes :preview_url

    embed :ids
    has_one :page
    has_one :author, embed_key: :username, include: true, serializer: AuthorSerializer

    def snapshot_attributes
      attrs = object.snapshot_attributes
      attrs[:meta_tags] ||= {}
      attrs
    end
  end
end
