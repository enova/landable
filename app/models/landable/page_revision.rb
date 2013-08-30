require_dependency 'landable/has_assets'

module Landable
  class PageRevision < ActiveRecord::Base
    include Landable::Engine.routes.url_helpers
    include Landable::HasAssets

    self.table_name = 'landable.page_revisions'

    store :snapshot_attributes, accessors: [:body]
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
    has_many   :screenshots, class_name: 'Landable::Screenshot', as: :screenshotable

    def page_id=(id)
      self[:page_id] = id
      self.snapshot_attributes = page.attributes.except(*self.ignored_page_attributes)
      self.snapshot_attributes['head_tags_attributes'] = page.head_tags.map(&:attributes)
    end

    def snapshot
      Page.new snapshot_attributes
    end

    def publish!
      update_attribute :is_published, true
    end

    def unpublish!
      update_attribute :is_published, false
    end

    def preview_url
      public_preview_page_revision_url(self)
    end
  end
end
