require_dependency 'landable/has_attachments'

module Landable
  class PageRevision < ActiveRecord::Base
    self.table_name = 'landable.page_revisions'
    include Landable::HasAttachments

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

    def page_id=(id)
      self[:page_id] = id
      snapshot_attributes[:attrs] = page.attributes.except(*self.ignored_page_attributes)
      self.attachments = page.attachments
    end

    def url
      Engine.routes.url_helpers.page_revision_url self
    end

    def snapshot
      attrs = snapshot_attributes[:attrs]
      Page.new attrs.merge(attachments: attachments)
    end

    def publish!
      update_attribute :is_published, true
    end

    def unpublish!
      update_attribute :is_published, false
    end
  end
end
