namespace :pgtap do
  task :check_for_pgprove do
    begin
      prove = sh "which pg_prove"
    rescue Exception=>e
       raise """
         PGTap and pg_prove must be installed!
         Reference http://pgtap.org/documentation.html#installation for installation instructions.
         """
    end
  end

  desc "Run PGTap unit tests"
  task :run, [:test_file] => [ :environment, :check_for_pgprove ] do |t, args|
    dbdir = "#{Rails.root}/../../db"

    tests = args[:test_file] ? args[:test_file] : "*.sql"

    # Load pgtap into database.  Will not complain if already loaded.
    ActiveRecord::Base.connection.execute(IO.read("#{dbdir}/pgtap/pgtap.sql"))

    # Run all unit tests (files ending in .sql) in db/test/
    sh "cd #{dbdir}/test && pg_prove -d #{ActiveRecord::Base.connection.current_database} #{tests}"
  end
end
