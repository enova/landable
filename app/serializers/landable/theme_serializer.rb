module Landable
  class ThemeSerializer < ActiveModel::Serializer
    attributes :name, :description
  end
end
