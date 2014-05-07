module Landable
  class TemplateSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description, :thumbnail_url, :slug, :is_layout, :editable, :file
  end
end
