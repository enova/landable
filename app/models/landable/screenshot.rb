module Landable
  class Screenshot < ActiveRecord::Base
    self.table_name = 'landable.screenshots'

    belongs_to :screenshotable, polymorphic: true, inverse_of: :screenshots

    validates_presence_of :screenshotable

    def page_revision_id= val
      self.screenshotable = PageRevision.find val
    end

    def page_id= val
      self.screenshotable = Page.find val
    end

    def url
      screenshotable.try(:preview_url)
    end

    # browserstack is inconsistent about this.
    def browser
      if self[:browser] == 'ie'
        'Internet Explorer'
      else
        self[:browser].try(:titleize)
      end
    end

    # browserstack is inconsistent about this.
    def os
      if self[:os] == 'ios'
        'iOS'
      elsif self[:os] == 'OS X'
        'OS X'
      else
        self[:os].try(:titleize)
      end
    end

    def browser_attributes
      attributes.slice 'device', 'os', 'os_version', 'browser', 'browser_version'
    end

  end
end
