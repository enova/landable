module Landable
  class TemplateSerializer < ActiveModel::Serializer
    attributes :id, :name, :body, :description, :screenshot_url
  end
end
