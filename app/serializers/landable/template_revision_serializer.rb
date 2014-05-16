require_dependency 'landable/author_serializer'

module Landable
  class TemplateRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal, :notes, :is_minor, :is_published
    attributes :created_at, :updated_at

    embed :ids
    has_one :template
    has_one :author, include: true, serializer: AuthorSerializer
  end
end
