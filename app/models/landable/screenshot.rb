module Landable
  class Screenshot < ActiveRecord::Base
    self.table_name = 'landable.screenshots'

    belongs_to :browser, class_name: 'Landable::Browser'
    belongs_to :screenshotable, polymorphic: true, inverse_of: :screenshots

    validates_presence_of :screenshotable
    validates_presence_of :browser

    delegate :browserstack_attributes, to: :browser

    def page_revision_id= val
      self.screenshotable = PageRevision.find val
    end

    def page_id= val
      self.screenshotable = Page.find val
    end

    def url
      screenshotable.try(:preview_url)
    end

  end
end
