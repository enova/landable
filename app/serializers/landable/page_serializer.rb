module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :path
    attributes :title, :body
    attributes :status_code, :redirect_url
    attributes :meta_tags
    has_one :theme, embed: :id

    def meta_tags
      object.meta_tags || {}
    end
  end
end
