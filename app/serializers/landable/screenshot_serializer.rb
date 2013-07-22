module Landable
  class ScreenshotSerializer < ActiveModel::Serializer
    attributes :id, :state
    attributes :device, :os, :os_version, :browser, :browser_version
    attributes :thumb_url, :image_url
    attributes :browserstack_id
    attributes :created_at, :updated_at
  end
end
