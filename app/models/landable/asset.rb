require_dependency 'landable/asset_uploader'
require 'carrierwave/orm/activerecord'

module Landable
  class Asset < ActiveRecord::Base
    self.table_name = 'landable.assets'
    mount_uploader :storage, Landable::AssetUploader
  end
end
