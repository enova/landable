require 'landable/version'
require "landable/engine"
require 'landable/liquid'
require 'landable/mime_types'
require "landable/inflections"
require "landable/tracking"

require "landable/core_ext/ipaddr"

module Landable
  # This absurd configuration loading code is not intended to live long.

  autoload :Configuration, 'landable/configuration'
  autoload :Layout,        'landable/layout'
  autoload :Seeds,         'landable/seeds'

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield configuration if block_given?
    configuration
  end
end
