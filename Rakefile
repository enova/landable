begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path("../spec/dummy/Rakefile", __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

require 'rdoc/task'
RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Landable'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rspec/core'
require 'rspec/core/rake_task'

# formerly, this depended on app:db:test:prepare. this loads the schema only,
# and - as it stands - our first migration contains needed seed data. for now,
# it's enough to ensure that bin/redb is run before testing.
desc "Run specs"
RSpec::Core::RakeTask.new(:spec)
task :default => :spec

load File.expand_path("../lib/tasks/cucumber.rake", __FILE__)
load File.expand_path("../lib/tasks/pgtap.rake", __FILE__)
