require "landable/engine"
require "yaml"

# This absurd configuration loading code is not intended to live long.
module Landable
  def self.themes
    @themes ||= []
  end

  def self.load_themes(file)
    config = YAML.load File.read(file)
    config.each do |attributes|
      themes.push Theme.new(attributes)
    end
  end
end
