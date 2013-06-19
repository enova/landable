module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :path
    attributes :title, :body
    attributes :status_code, :redirect_url
    attributes :meta_tags
    attributes :is_publishable

    embed :ids
    has_one  :theme
    has_one  :published_revision
    has_many :assets

    def meta_tags
      object.meta_tags || {}
    end
  end
end
