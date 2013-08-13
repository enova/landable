require "landable/engine"
require "landable/configuration"
require "yaml"
require "csv"

# This absurd configuration loading code is not intended to live long.
module Landable
  def self.configuration
    @configuration ||= Landable::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
    configuration
  end
end
