module Landable
  class ThemeSerializer < ActiveModel::Serializer
    attributes :id, :name, :editable, :body, :description, :thumbnail_url, :deleted_at

    embed :ids
  end
end
