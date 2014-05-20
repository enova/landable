module Landable
  class TemplateSerializer < ActiveModel::Serializer

    attributes :body, :deleted_at, :description, :editable, :file, :id, 
               :is_layout, :is_publishable, :name, :slug, :thumbnail_url

    embed    :ids
    has_one  :published_revision
  end
end
