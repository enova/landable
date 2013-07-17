require 'yaml'
require 'erb'

namespace :db do
  namespace :pgtap do
    task :read_config do
      $env = ENV['env'] || ENV['RAILS_ENV'] || 'development'
      $cfg = YAML.load(ERB.new(File.read("config/database.yml")).result)
      puts (ENV['dbs'] || '').split(/,|\s+/).inspect
    end
    
    desc "Run pgTap unit tests"
    task :run => [ :read_config ] do
      env = $env
      cfg = $cfg

      c = cfg['test'] or raise "no database config for #{test.inspect}"
      sh "cd ../../db/test && PGUSER=postgres pg_prove -d #{c['database']} *.sql"
    end


    desc "Install pgTap"
    task :install => [ :read_config ] do
      env = $env
      cfg = $cfg

      c = cfg['test'] or raise "no database config for #{test.inspect}"
      sh "sudo -u postgres psql -f ../../db/pgtap/pgtap.sql #{c['database']} > pgtap.install.log"
    end
  end
end
