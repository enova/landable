namespace :landable do
  namespace :data do
    task restore: :environment do
       STDOUT.puts 'Enter Remote DB Host'
       host = STDIN.gets.strip

       STDOUT.puts 'Enter Remote Database'
       database = STDIN.gets.strip

       STDOUT.puts 'Enter Remote Username'
       username = STDIN.gets.strip

       `pg_dump -h #{host} -U #{username} --data-only --format plain --schema landable #{database} > landable_import.sql`

       `psql #{Rails.configuration.database_configuration[Rails.env]["database"]} -f landable_import.sql`
    end
  end
end