require_dependency 'landable/has_assets'

module Landable
  class PageRevision < ActiveRecord::Base
    include Landable::Engine.routes.url_helpers
    include Landable::HasAssets
    include Landable::TableName

    @@ignored_page_attributes = [
      'page_id',
      'imported_at',
      'created_at',
      'updated_at',
      'published_revision_id',
      'is_publishable',
      'updated_by_author_id',
      'lock_version'
    ]

    cattr_accessor :ignored_page_attributes

    belongs_to :author
    belongs_to :page, inverse_of: :revisions
    has_many   :screenshots, class_name: 'Landable::Screenshot', as: :screenshotable

    def page_id=(id)
      # set the value
      self[:page_id] = id

      # copy grab attributes from the page
      self.title          = page.title
      self.body           = page.body
      self.head_content   = page.head_content
      self.path           = page.path
      self.status_code    = page.status_code
      self.category_id    = page.category_id
      self.theme_id       = page.theme_id
      self.meta_tags      = page.meta_tags
      self.redirect_url   = page.redirect_url
    end

    def snapshot
      Page.new(title: self.title, 
               meta_tags: page.meta_tags, 
               head_content: page.head_content,
               body: self.body, 
               path: self.path, 
               redirect_url: self.redirect_url, 
               status_code: self.status_code, 
               theme_id: self.theme_id, 
               category_id: self.category_id)
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

    def preview_path
      public_preview_page_revision_path(self)
    end
  end
end
