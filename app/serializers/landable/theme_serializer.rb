module Landable
  class ThemeSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description, :thumbnail_url

    embed :ids
    has_many :assets
  end
end
