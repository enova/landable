module Landable
  class ThemeSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description
  end
end
