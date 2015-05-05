require 'highline'

require_dependency 'schema_moves'
include SchemaMoves::Helpers

namespace :landable do
  namespace :data do
    desc 'Clean & restore database from specified source'
    task restore: ['db:drop', 'db:create', 'db:migrate', 'dump_and_load']

    desc 'Restore database from specified source'
    task dump_and_load: :environment do
      STDOUT.puts 'Enter Remote DB Host'
      host = STDIN.gets.strip

      STDOUT.puts 'Enter Remote Database'
      database = STDIN.gets.strip

      STDOUT.puts 'Enter Remote Username'
      username = STDIN.gets.strip

      `pg_dump -h #{host} -U #{username} --data-only --format plain --schema landable #{database} > landable_import.sql`
      `psql #{Rails.configuration.database_configuration[Rails.env]['database']} -f landable_import.sql`
      `rm landable_import.sql`
    end

    desc 'Migrates all to new schema'
    task move_schemas: :environment do
      get_schema_names
      create_schemas
      migrate_objects
      drop_old_schemas if want_to_drop_old_schemas?
    end

    desc 'Drop the old schemas'
    task drop_schemas: :environment do
      get_schema_names false
      drop_old_schemas if want_to_drop_old_schemas?
    end
  end
end
