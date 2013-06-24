require_dependency 'landable/asset_uploader'

require 'carrierwave/orm/activerecord'
require 'digest/md5'

module Landable
  class Asset < ActiveRecord::Base
    self.table_name = 'landable.assets'
    mount_uploader :data, Landable::AssetUploader

    # This bit of indirection allows us to generate predictable
    # URLs in the test environment.
    def self.url_generator
      @url_generator ||= proc { |asset| asset.data.try(:url) }
    end

    belongs_to :author

    has_many :page_assets
    has_many :theme_assets
    has_many :pages, through: :page_assets
    has_many :themes, through: :theme_assets

    before_validation :write_metadata, on: :create

    validates_presence_of     :data, :author_id
    validates_presence_of     :name, :basename, :mime_type, :md5sum, :file_size
    validates_uniqueness_of   :md5sum
    validates_numericality_of :file_size, only_integer: true

    def public_url
      self.class.url_generator.call(self)
    end

    def duplicate_of
      return unless data.present?
      self.class.where(md5sum: calculate_md5sum).first
    end

    private

    def calculate_md5sum
      Digest::MD5.hexdigest(data.read) if data.present?
    end

    def write_metadata
      return unless data.present?
      self.md5sum    = calculate_md5sum
      self.basename  = data.filename
      self.mime_type = data.file.content_type
      self.file_size = data.file.size
    end
  end
end
