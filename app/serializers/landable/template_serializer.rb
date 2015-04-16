module Landable
  class TemplateSerializer < ActiveModel::Serializer
    attributes :id
    attributes :name, :body, :description
    attributes :thumbnail_url, :slug
    attributes :is_layout, :is_publishable
    attributes :file, :editable
    attributes :audit_flags
    attributes :deleted_at

    embed :ids
    has_one :published_revision

    has_many :pages
  end
end
