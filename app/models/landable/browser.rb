module Landable
  class Browser < ActiveRecord::Base

    self.table_name = 'landable.browsers'

    has_many :screenshots

    def name
      if mobile?
        device
      else
        "#{browser_name} #{browser_version} (#{os_name} #{os_version})"
      end
    end

    def is_mobile
      !!device.presence
    end

    alias :mobile? :is_mobile

    def browserstack_attributes
      attributes.slice 'device', 'os', 'os_version', 'browser', 'browser_version'
    end

    # browserstack is inconsistent about this
    def browser_name
      if browser == 'ie'
        'Internet Explorer'
      else
        browser.try(:titleize)
      end
    end

    # browserstack is inconsistent about this
    def os_name
      if os == 'ios'
        'iOS'
      elsif os == 'OS X'
        os
      else
        os.try(:titleize)
      end
    end

  end
end