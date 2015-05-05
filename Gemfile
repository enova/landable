source 'https://rubygems.org'

# load dependencies from landable.gemspec
gemspec

# allow us to load up a specific version of rails, since the gemspec is
# concerned only with compatibility (see bin/test)
gem 'rails', ENV['RAILS_VERSION'] if ENV.key? 'RAILS_VERSION'

# development/test dependencies, and anything else that doesn't belong or fit
# in the gemspec
group :test do
  gem 'rubocop'
  gem 'minitest'
  gem 'shoulda-matchers'
  gem 'cucumber-rails', require: false
  gem 'test_after_commit'
end
