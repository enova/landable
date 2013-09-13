namespace :landable do
  begin
    require 'rspec/core'
    require 'rspec/core/rake_task'

    desc 'Run specs'
    RSpec::Core::RakeTask.new(:spec)

  rescue LoadError
    desc 'Run specs (missing rspec)'
    task :spec do
      raise 'rspec not present'
    end
  end
end
