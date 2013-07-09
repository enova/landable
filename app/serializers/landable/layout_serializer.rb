module Landable
  class LayoutSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description, :screenshot_url
  end
end
