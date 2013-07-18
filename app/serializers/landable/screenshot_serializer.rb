module Landable
  class ScreenshotSerializer < ActiveModel::Serializer
    attributes :id
    attributes :device, :os, :os_version, :browser, :browser_version
    attributes :thumb_url, :image_url
    attributes :browserstack_id
  end
end
