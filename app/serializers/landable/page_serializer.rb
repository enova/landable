module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :path, :theme_name
    attributes :title, :body
    attributes :status_code, :redirect_url
    attributes :meta_tags

    has_one :theme, embed: :object

    def meta_tags
      object.meta_tags || {}
    end
  end
end
