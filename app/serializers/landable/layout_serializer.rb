module Landable
  class LayoutSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description
  end
end
