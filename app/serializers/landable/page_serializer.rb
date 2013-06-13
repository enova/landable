module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :path
    attributes :title, :body
    attributes :status_code, :redirect_url
    attributes :meta_tags
    attributes :is_publishable

    has_one :theme, embed: :id
    has_one :published_revision, embed: :id

    def meta_tags
      object.meta_tags || {}
    end
  end
end
