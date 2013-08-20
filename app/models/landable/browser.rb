module Landable
  class Browser < ActiveRecord::Base

    self.table_name = 'landable.browsers'

    has_many :screenshots

    # TODO do this in a way that doesn't suck
    def name
      [
        browserstack_attributes['device'].to_s,
        browserstack_attributes['os'].to_s,
        browserstack_attributes['os_version'].to_s,
        browserstack_attributes['browser'].to_s,
        browserstack_attributes['browser_version'].to_s,
      ].join(' ')
    end

    def is_mobile
      !!device.presence
    end

    def browserstack_attributes
      attributes.slice 'device', 'os', 'os_version', 'browser', 'browser_version'
    end

  end
end