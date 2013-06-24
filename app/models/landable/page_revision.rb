module Landable
  class PageRevision < ActiveRecord::Base
    self.table_name = 'landable.page_revisions'
    store :snapshot_attributes, accessors: [ :attrs ]

    @@ignored_page_attributes = [
      'page_id',
      'imported_at',
      'created_at',
      'updated_at',
      'published_revision_id',
      'is_publishable',
    ]
    cattr_accessor :ignored_page_attributes

    belongs_to :author
    belongs_to :page, inverse_of: :revisions

    has_many :page_revision_assets
    has_many :assets, :through => :page_revision_assets

    def page_id=(id)
      self[:page_id] = id
      snapshot_attributes[:attrs] = page.attributes.except(*self.ignored_page_attributes)

      page.page_assets.pluck(:asset_id, :alias).each do |(id, als)|
        page_revision_assets.build(asset_id: id, alias: als)
      end
    end

    def snapshot
      Page.new(snapshot_attributes[:attrs]).tap do |page|
        # ech, gross. perhaps an AssetRepository or similar to deal with this tedium?
        # that way the rest of the world doesn't have to dance through associations.
        page_revision_assets.each do |record|
          page.assets << record.asset
          join = page.page_assets.find { |pa| pa.asset_id == record.asset_id }
          join.alias = record.alias
        end
      end
    end

    def publish!
      update_attribute :is_published, true
    end

    def unpublish!
      update_attribute :is_published, false
    end
  end
end
