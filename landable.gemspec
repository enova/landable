$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "landable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "landable"
  s.version     = Landable::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Landable."
  s.description = "TODO: Description of Landable."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.0.0.rc1"

  s.add_development_dependency "pg"
end
