module Landable
  class ThemeSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description

    embed :ids
    has_many :assets
  end
end
