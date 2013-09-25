require 'landable/engine'
require 'landable/configuration'
require 'landable/seeds'
require 'landable/liquid'

module Landable
  # This absurd configuration loading code is not intended to live long.
  def self.configuration
    @configuration ||= Landable::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
    configuration
  end
end
