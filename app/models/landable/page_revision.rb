module Landable
  class PageRevision < ActiveRecord::Base
    self.table_name = 'landable.page_revisions'

    belongs_to :author
    belongs_to :page, inverse_of: :revisions

    def page_id=(the_page_id)
      self[:page_id] = the_page_id

      # copy over attributes from our new page
      self.page_title ||= page.title
      self.page_path ||= page.path
      self.page_body ||= page.body
      self.page_status_code ||= page.status_code
      self.page_redirect_url ||= page.redirect_url
      self.page_meta_tags ||= page.meta_tags.try :clone
    end
  end
end