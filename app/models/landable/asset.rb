require_dependency 'landable/asset_uploader'

require 'carrierwave/orm/activerecord'
require 'digest/md5'

module Landable
  class Asset < ActiveRecord::Base
    self.table_name = "#{Landable.configuration.schema_prefix}landable.assets"

    mount_uploader :data, Landable::AssetUploader
    alias :file :data
    alias :file= :data=

    # This bit of indirection allows us to generate predictable
    # URLs in the test environment.
    def self.url_generator
      @url_generator ||= proc { |asset| asset.data.try(:url) }
    end

    belongs_to :author
    has_and_belongs_to_many :pages, join_table: Page.assets_join_table_name
    has_and_belongs_to_many :page_revisions, join_table: PageRevision.assets_join_table_name
    has_and_belongs_to_many :themes, join_table: Theme.assets_join_table_name

    before_validation :write_metadata, on: :create

    validates_presence_of     :data, :author
    validates_presence_of     :name, :mime_type, :md5sum, :file_size
    validates_uniqueness_of   :md5sum
    validates_numericality_of :file_size, only_integer: true
    validates_format_of       :name, :with => /^[\w\._-]+$/, :on => :create, :multiline => true, :message => 'can only contain alphanumeric characters, periods, underscores, and dashes'

    def public_url
      self.class.url_generator.call(self)
    end

    def duplicate_of
      return unless data.present?
      self.class.where(md5sum: calculate_md5sum).first
    end

    def associated_pages
      paths = []
      Page.where("body like ?", "%#{self.name}%").each do |page|
        paths.push(page.path)
      end
      paths
    end

    private

    def calculate_md5sum
      Digest::MD5.hexdigest(data.read) if data.present?
    end

    def write_metadata
      return unless data.present?
      self.md5sum    = calculate_md5sum
      self.mime_type = data.file.content_type.presence || 'application/octet-stream'
      self.file_size = data.file.size
    end
  end
end
