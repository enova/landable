require_dependency 'landable/asset_uploader'

require 'carrierwave/orm/activerecord'
require 'digest/md5'

module Landable
  class Asset < ActiveRecord::Base
    self.table_name = 'landable.assets'
    mount_uploader :data, Landable::AssetUploader

    belongs_to :author

    has_many :page_assets
    has_many :theme_assets
    has_many :pages, through: :page_assets
    has_many :themes, through: :theme_assets

    before_validation :write_metadata, on: :create

    validates_presence_of   :data
    validates_presence_of   :basename, :mime_type, :md5sum, :file_size
    validates_uniqueness_of :md5sum

    def duplicate_of
      self.class.where(md5sum: calculate_md5sum).first
    end

    private

    def calculate_md5sum
      @sum ||= Digest::MD5.hexdigest(data.read)
    end

    def write_metadata
      self.md5sum    = calculate_md5sum
      self.basename  = data.filename
      self.mime_type = data.file.content_type
      self.file_size = data.file.size
    end
  end
end
