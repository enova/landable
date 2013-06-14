module Landable
  class PageRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal, :notes, :is_minor
    attributes :snapshot_attributes
    attributes :created_at

    embed :ids
    has_one :page
    has_one :theme
    has_one :author, embed_key: :username, include: true, serializer: AuthorSerializer

    def theme_id
      object.snapshot_attributes[:theme_id]
    end

    def theme
      Theme.find(theme_id) if theme_id
    end
  end
end
