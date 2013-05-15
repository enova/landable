$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "landable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "landable"
  s.version     = Landable::VERSION
  s.authors     = ["Team Trogdor"]
  s.email       = ["trogdor@cashnetusa.com"]
  s.homepage    = "http://git.cashnetusa.com/trogdor/landable"
  s.summary     = "Mountable CMS engine for Rails"
  s.description = "Mountable CMS engine for Rails"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.0.0.rc1"
  s.add_dependency "rack-cors", ">= 0.2.7"
  s.add_dependency "active_model_serializers", "~> 0.8"

  s.add_development_dependency "pg"
  s.add_development_dependency "rspec-rails", '~> 2.13.0'
  s.add_development_dependency "factory_girl_rails", '~> 4.2.0'
  s.add_development_dependency "combustion", '~> 0.5.0'
end
