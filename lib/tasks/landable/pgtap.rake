namespace :landable do
  namespace :pgtap do
    def has_pgprove?
      @@has_prove ||= Kernel.system('which pg_prove > /dev/null')
    end

    def has_pgconfig?
      @@has_pgconfig ||= Kernel.system('which pg_config > /dev/null')
    end

    def has_pgtap?
      if has_pgconfig?
        sharedir = "#{`pg_config | grep SHAREDIR | awk {' print $3 '}`.strip}/extension/pgtap.control"
        if File.file?("#{sharedir}")
          return true
        else
          return false
        end
      end
    end

    desc "Run PGTap unit tests"
    task :run, [:test_file] => [ :environment ] do |t, args|
      dbdir = "#{Rails.root}/../../db"

      tests = args[:test_file] ? args[:test_file] : "*.sql"

      if has_pgprove? and has_pgtap?
        # Load pgtap functions into database.  Will not complain if already loaded.
        ActiveRecord::Base.connection.execute("CREATE EXTENSION IF NOT EXISTS pgtap;")

        # Runs the tests.  Wrapped pg_prove call in shell script due to issues with return values
        sh "cd #{Rails.root}/../../script && ./pgtap"
      else
        puts "\nPGTap and/or pg_prove not installed.  Skipping DB unit tests"
        puts "Reference 'http://pgtap.org/documentation.html#installation' for installation instructions."
      end
    end
  end

  task :pgtap => 'pgtap:run'
end
