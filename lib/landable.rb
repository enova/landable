require "landable/engine"
require "yaml"

# This absurd configuration loading code is not intended to live long.
module Landable
  def self.themes
    @themes ||= []
  end

  def self.load_themes(file)
    config = YAML.load File.read(file)
    config.each do |theme|
      themes.push Theme.new(theme['name'], theme['description'], theme['screenshot_urls'])
    end
  end
end
