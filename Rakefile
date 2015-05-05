begin
  require 'bundler/setup'
  require 'rubocop/rake_task'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

APP_RAKEFILE = File.expand_path('../spec/dummy/Rakefile', __FILE__)
load 'rails/tasks/engine.rake'

Bundler::GemHelper.install_tasks

Dir.glob(File.expand_path('../lib/tasks/landable/*.rake', __FILE__)).each { |f| load f }

desc 'Landable test suite'
task landable: [
  'rubocop',
  'app:db:test:prepare',
  'landable:seed',
  'landable:spec',
  'landable:cucumber',
  'landable:pgtap'
]
RuboCop::RakeTask.new
