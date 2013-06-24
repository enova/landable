# encoding: utf-8
require 'carrierwave'

module Landable
  class AssetUploader < CarrierWave::Uploader::Base
    include CarrierWave::MimeTypes
    process :set_content_type

    # This should, perhaps, be moved elsewhere and/or made configurable
    # in a fashion more reasonable than "re-open the class". It is not
    # yet clear to me how that should be done, though, so here we are:
    storage :fog
  end
end
