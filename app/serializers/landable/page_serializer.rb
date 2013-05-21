module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :title, :body
    has_one :theme, embed: :object
  end
end
