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

load File.expand_path('../lib/tasks/landable.rake', __FILE__)
load File.expand_path('../lib/tasks/cucumber.rake', __FILE__)
load File.expand_path('../lib/tasks/pgtap.rake', __FILE__) if Rails.root.to_s.split('/').last == 'dummy'

require 'rspec/core'
require 'rspec/core/rake_task'

desc 'Run specs'
RSpec::Core::RakeTask.new(:spec)

# reclaim our default task
task(:default).clear

desc 'Landable test suite'
task :default => ['app:db:test:prepare', 'landable:seed:required', :spec, :cucumber, :pgtap]
