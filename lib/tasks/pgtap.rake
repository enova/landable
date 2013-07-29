begin
  namespace :pgtap do
    def has_pgprove?
      @@has_prove ||= Kernel.system('which pg_dumpy_thing > /dev/null')
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
        ActiveRecord::Base.connection.execute(IO.read("#{dbdir}/pgtap/pgtap.sql"))

        sh "cd #{dbdir}/test && pg_prove -d #{ActiveRecord::Base.connection.current_database} #{tests}"
      end
    end
  end
  task :pgtap => 'pgtap:run'
  task :default => :pgtap
end
