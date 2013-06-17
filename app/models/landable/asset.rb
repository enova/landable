require_dependency 'landable/asset_uploader'
require 'carrierwave/orm/activerecord'

module Landable
  class Asset < ActiveRecord::Base
    self.table_name = 'landable.assets'
    mount_uploader :content, Landable::AssetUploader
    alias_attribute :filename, :basename

    belongs_to :author

    has_many :page_assets
    has_many :theme_assets
    has_many :pages, through: :page_assets
    has_many :themes, through: :theme_assets
  end
end
