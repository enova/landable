module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :title, :body
  end
end
