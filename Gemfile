source "http://gems.enova.com"
source "https://rubygems.org"

# load dependencies from landable.gemspec
gemspec

# allow us to load up a specific version of rails, since the gemspec is
# concerned only with compatibility (see bin/test)
if ENV.key? 'RAILS_VERSION'
  gem 'rails', ENV['RAILS_VERSION']
end

# development/test dependencies, and anything else that doesn't belong or fit
# in the gemspec
group :test do
  gem 'minitest'
  gem 'shoulda-matchers'
  gem 'cucumber-rails', require: false
end
