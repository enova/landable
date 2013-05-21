module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :path, :title, :body
    has_one :theme, embed: :object
  end
end
