module Landable
  class ScreenshotSerializer < ActiveModel::Serializer
    attributes :id, :state
    attributes :thumb_url, :image_url
    attributes :browserstack_id
    attributes :created_at, :updated_at

    has_one :browser
  end
end
