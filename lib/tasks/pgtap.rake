namespace :pgtap do
  def check_for_pgtap
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
  task :run => [ :environment ] do
    dbdir = "#{Rails.root}/../../db"

    check_for_pgtap

    ActiveRecord::Base.connection.execute(IO.read("#{dbdir}/pgtap/pgtap.sql"))
    sh "cd #{dbdir}/test && pg_prove -d #{ActiveRecord::Base.connection.current_database} *.sql"
  end
end
