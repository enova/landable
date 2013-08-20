module Landable
  class BrowserSerializer < ActiveModel::Serializer
    attributes :id
    attributes :device, :os, :os_version, :browser, :browser_version
    attributes :is_mobile
  end
end