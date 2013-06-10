module Landable
  class ThemeSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description, :screenshot_url
  end
end
