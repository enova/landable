require "landable/engine"
require "yaml"

# This absurd configuration loading code is not intended to live long.
module Landable
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

  def self.cors_origins=(origins)
    @cors_origins = origins
  end

  def self.cors_origins
    @cors_origins ||= ['publicist.dev']
  end

  def self.cors_resources=(resources)
    @cors_resources = resources
  end

  def self.cors_resources
    @cors_resources ||= ['/landable/*']
  end
end
