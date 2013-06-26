require_dependency 'landable/author_serializer'
require_dependency 'landable/theme'

module Landable
  class PageRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal, :notes, :is_minor, :is_published
    attributes :snapshot_attributes
    attributes :created_at
    attributes :url

    embed :ids
    has_one :page
    has_one :theme
    has_one :author, include: true, serializer: AuthorSerializer

    def snapshot_attributes
      attrs = object.snapshot_attributes[:attrs]
      attrs[:meta_tags] ||= {}
      attrs
    end

    def url
      page_revision_url(object)
    end

    def theme_id
      snapshot_attributes[:theme_id]
    end

    def theme
      Theme.find(theme_id) if theme_id
    end
  end
end
