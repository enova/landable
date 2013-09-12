require 'rspec/core'
require 'rspec/core/rake_task'

namespace :landable do
  desc 'Run specs'
  RSpec::Core::RakeTask.new(:spec)
end