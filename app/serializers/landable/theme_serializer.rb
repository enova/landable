module Landable
  class ThemeSerializer < ActiveModel::Serializer
    attributes :name, :description, :layout, :screenshot_urls
  end
end
