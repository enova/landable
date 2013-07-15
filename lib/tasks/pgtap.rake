require 'yaml'
require 'erb'

namespace :db do
  namespace :pgtap do
    task :read_config do
      $env = ENV['env'] || ENV['RAILS_ENV'] || 'development'
      $cfg = YAML.load(ERB.new(File.read("config/database.yml")).result)
      puts (ENV['dbs'] || '').split(/,|\s+/).inspect
    end
    
    desc "Create Schema & Extension pgTap"
    task :create_extension => [ :read_config ] do
      env = $env
      cfg = $cfg

      t = 'development'
      c = cfg[t] or raise "no database config for #{t.inspect}"

      [ 'development', 'test' ].each do | t |
        c = cfg[t] or raise "no database config for #{t.inspect}"
        # E.g: db = ENV['db'] || c['database']
        checkpgtap = `sudo -u postgres psql #{c['database']} -A -t -c "SELECT count(*) from pg_namespace WHERE nspname='pgtap';"`
        puts "Does pgtap schema already exists in database #{c['database']}? Result: #{checkpgtap}"
        if (checkpgtap.to_i ==0)
                installpgtap = `sudo -u postgres psql #{c['database']} -c "CREATE SCHEMA pgtap; GRANT ALL ON SCHEMA pgtap TO public; CREATE EXTENSION IF NOT EXISTS pgtap WITH SCHEMA pgtap;"`
                puts "Create schema & extension succeeded."
        elsif (checkpgtap.to_i==1)
                puts "Pgtap already installed. Skipped creating schema."
        else
                puts "Unknown DB response. Skipping pgtap schema creation."
        end
      end
    end

    desc "Run pgTap unit tests"
    task :run => [ :read_config ] do
      env = $env
      cfg = $cfg

      c = cfg['test'] or raise "no database config for #{test.inspect}"
      sh "PGUSER=postgres pg_prove -d #{c['database']} ../../db/test/*.sql"
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

# Example on how to reuse tasks in other namespaces
#namespace :ns do
#  task :do_something_with_database => [ 'db:pgtap:read_config' ] do
#    puts $cfg.inspect
#  end
#end
