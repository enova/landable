module Landable
  class TemplateSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description, :thumbnail_url
  end
end
