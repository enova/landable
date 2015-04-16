require_dependency 'landable/author_serializer'
require_dependency 'landable/theme'

module Landable
  class PageRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal, :notes, :is_minor, :is_published
    attributes :created_at, :updated_at
    attributes :preview_path
    attributes :screenshot_url

    embed :ids
    has_one :page
    has_one :author, include: true, serializer: AuthorSerializer
  end
end
