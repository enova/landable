namespace :landable do
  namespace :pgtap do
    def pgprove?
      @has_prove ||= Kernel.system('which pg_prove > /dev/null')
    end

    def pgconfig?
      @has_pgconfig ||= Kernel.system('which pg_config > /dev/null')
    end

    def pgtap?
      has_pgtap = false

      if pgconfig?
        sharedir = "#{`pg_config | grep SHAREDIR | awk {' print $3 '}`.strip}/extension/pgtap.control"
        has_pgtap = true if File.file?("#{sharedir}")
      end

      has_pgtap
    end

    desc 'Run PGTap unit tests'
    task :run, [:test_file] => [:environment] do |_t, _args|
      if pgprove? && pgtap?
        # Load pgtap functions into database.  Will not complain if already loaded.
        ActiveRecord::Base.connection.execute('CREATE EXTENSION IF NOT EXISTS pgtap;')

        # Runs the tests.  Wrapped pg_prove call in shell script due to issues with return values
        sh "cd #{Rails.root}/../../script && ./pgtap"
      else
        puts "\nPGTap and/or pg_prove not installed.  Skipping DB unit tests"
        puts "Reference 'http://pgtap.org/documentation.html#installation' for installation instructions."
      end
    end
  end

  task pgtap: 'pgtap:run'
end
