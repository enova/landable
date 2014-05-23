namespace :landable do
  namespace :pgtap do
    def has_pgprove?
      @@has_prove ||= Kernel.system('which pg_prove > /dev/null')
    end

    desc "Run PGTap unit tests"
    task :run, [:test_file] => [ :environment ] do |t, args|
      dbdir = "#{Rails.root}/../../db"

      tests = args[:test_file] ? args[:test_file] : "*.sql"

      if not has_pgprove?
        puts "\nPGTap not installed.  Skipping DB unit tests"
        puts "Reference 'http://pgtap.org/documentation.html#installation' for installation instructions."
      else
        # Load pgtap functions into database.  Will not complain if already loaded.
        ActiveRecord::Base.connection.execute("CREATE EXTENSION pgtap;")
        sh "cd #{Rails.root}/../../script && ./pgtap"
      end
    end
  end

  task :pgtap => 'pgtap:run'
end
