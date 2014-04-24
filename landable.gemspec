# coding: utf-8

lib = File.expand_path('../lib', __FILE__)
$:.unshift(lib) unless $:.include?(lib)

# Maintain your gem's version:
require 'landable/version'

# Describe your gem and declare its dependencies:
Gem::Specification.new do |gem|
  gem.name          = 'landable'
  gem.version       = Landable::VERSION::STRING

  gem.authors       = ['Team Trogdor']
  gem.email         = ['trogdor@enova.com']

  gem.homepage      = 'https://github.com/enova/landable'

  gem.license       = 'MIT-LICENSE'

  gem.summary       = 'Mountable CMS engine for Rails'
  gem.description   = 'Landing page storage, rendering, tracking, and management API'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.executables   = gem.files.grep(%r{^bin/}) { |f| File.basename(f) }

  gem.require_paths = ['lib']

  gem.add_dependency 'rails',     '~> 4.0'
  gem.add_dependency 'rack-cors', '>= 0.2.7'
  gem.add_dependency 'active_model_serializers', '~> 0.8'
  gem.add_dependency 'carrierwave'
  gem.add_dependency 'liquid'
  gem.add_dependency 'fog'
  gem.add_dependency 'rest-client'
  gem.add_dependency 'builder'
  gem.add_dependency 'lookup_by', '> 0.4.0'

  gem.add_development_dependency 'pg'
  gem.add_development_dependency 'rspec-rails',        '~> 2.14.2'
  gem.add_development_dependency 'factory_girl_rails', '~> 4.2.0'
  gem.add_development_dependency 'json-schema',        '= 2.1.3'
  gem.add_development_dependency 'rack-schema'
  gem.add_development_dependency 'cucumber',           '= 1.3.2'
  gem.add_development_dependency 'database_cleaner'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'valid_attribute'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'faker'
  gem.add_development_dependency 'bundler_geminabox'
end
