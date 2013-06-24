# encoding: utf-8
require 'carrierwave'

module Landable
  class AssetUploader < CarrierWave::Uploader::Base
    include CarrierWave::MimeTypes
    process :set_content_type
  end
end
