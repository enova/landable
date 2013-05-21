module Landable
  class ThemeSerializer < ActiveModel::Serializer
    attributes :name, :description, :screenshot_urls
  end
end
