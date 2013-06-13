require_dependency 'landable/asset_uploader'
require 'carrierwave/orm/activerecord'

module Landable
  class Asset < ActiveRecord::Base
    self.table_name = 'landable.assets'
    mount_uploader :content, Landable::AssetUploader
    alias_attribute :filename, :basename
  end
end
