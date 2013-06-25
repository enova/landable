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

    def page_id=(the_page_id)
      self[:page_id] = the_page_id

      # copy over attributes from our new page
      self.snapshot_attributes[:attrs] ||= page.attributes.reject { |key| self.ignored_page_attributes.include? key }
    end

    def url
      Engine.routes.url_helpers.page_revision_url self
    end

    def snapshot
      Page.new snapshot_attributes[:attrs]
    end

    def publish!
      self.is_published = true
      save!
    end

    def unpublish!
      self.is_published = false
      save!
    end
  end
end
