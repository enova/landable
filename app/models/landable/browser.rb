module Landable
  class Browser < ActiveRecord::Base

    self.table_name = 'landable.browsers'

    has_many :screenshots

    def is_mobile
      !!device.presence
    end

    def browserstack_attributes
      attributes.slice 'device', 'os', 'os_version', 'browser', 'browser_version'
    end

  end
end