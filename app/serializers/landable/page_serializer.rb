module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :path, :theme_name
    attributes :title, :body
    attributes :status_code, :redirect_url

    has_one :theme, embed: :object
  end
end
