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

    after_commit :add_screenshot!, on: :create

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
      self.abstract       = page.abstract
      self.hero_asset_id  = page.hero_asset_id
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
               category_id: self.category_id,
               abstract: self.abstract,
               hero_asset_id: self.hero_asset_id)
    end

    def publish!
      update_attribute :is_published, true
    end

    def unpublish!
      update_attribute :is_published, false
    end

    def preview_url
      begin
        public_preview_page_revision_url(self, host: Landable.configuration.public_host)
      rescue ArgumentError
        Rails.logger.warn "Failed to generate preview url for page revision #{id} - missing Landable.configuration.public_host"
        nil
      end
    end

    def preview_path
      public_preview_page_revision_path(self)
    end

    mount_uploader :screenshot, Landable::AssetUploader

    def screenshot_url
      screenshot.try(:url)
    end

    def add_screenshot!
      return nil if preview_url.blank?

      unless Landable.configuration.screenshots_enabled
        Rails.logger.info "Screenshots disabled; skipping for #{path}"
        return
      end

      attempts_left = 3

      begin
        attempts_left -= 1

        self.screenshot = ScreenshotService.capture(preview_url)

        # we've got a trigger preventing updates to other columns, so! muck
        # about under the hood to commit the asset, and explicitly only update
        # this column.
        store_screenshot!
        write_screenshot_identifier
        update_column :screenshot, self[:screenshot]

      rescue ScreenshotService::Error => error
        Rails.logger.warn "Failed to generate screenshot (#{attempts_left} attempt(s) left) for #{path}: #{error.inspect}"

        retry if attempts_left > 0
      end
    end
  end

end
