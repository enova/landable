require "landable/engine"
require "landable/configuration"
require "yaml"

# This absurd configuration loading code is not intended to live long.
module Landable
  def self.configuration
    @configuration ||= Landable::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
    configuration
  end

  def self.themes
    @themes ||= []
  end

  def self.find_theme(name)
    themes.find { |theme| theme.name == name }
  end

  def self.load_themes(file)
    config = YAML.load File.read(file)
    config.each do |attributes|
      themes.push Theme.new(attributes)
    end
  end
end
