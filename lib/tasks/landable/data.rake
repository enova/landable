namespace :landable do
  namespace :data do
    desc "Clean & restore database from specified source"
    task :restore => [ 'db:drop', 'db:create', 'db:migrate', 'dump_and_load' ]

    desc 'Restore database from specified source'
    task dump_and_load: :environment do
       STDOUT.puts 'Enter Remote DB Host'
       host = STDIN.gets.strip

       STDOUT.puts 'Enter Remote Database'
       database = STDIN.gets.strip

       STDOUT.puts 'Enter Remote Username'
       username = STDIN.gets.strip

       `pg_dump -h #{host} -U #{username} --data-only --format plain --schema landable #{database} > landable_import.sql`
       `psql #{Rails.configuration.database_configuration[Rails.env]["database"]} -f landable_import.sql`
       `rm landable_import.sql`
    end

    desc "Migrates all to new schema"
    task :move_schemas, :old_landable, :new_landable, :old_traffic, :new_traffic do |t, args|
      @old_landable = "#{args[:old_landable]}"
      @new_landable = "#{args[:new_landable]}"
      @old_traffic = "#{args[:old_traffic]}"
      @new_traffic = "#{args[:new_traffic]}"

      Rake.application.invoke_task("landable:data:create_schemas")
      Rake.application.invoke_task("landable:data:move_tables")
      Rake.application.invoke_task("landable:data:move_sequences")
      Rake.application.invoke_task("landable:data:move_triggers")
    end

    desc "Creates the new schemas"
    task create_schemas: :environment do
      create_schema("#{@new_landable}")
      create_schema("#{@new_traffic}")
    end

    desc "Move tables to new db schema"
    task move_tables: :environment do
      move_objects("#{@old_landable}", "#{@new_landable}", 'r', 'TABLE')
      move_objects("#{@old_traffic}", "#{@new_traffic}", 'r', 'TABLE')
    end

    desc "Move sequences to new db schema"
    task move_sequences: :environment do
      move_objects("#{@old_landable}", "#{@new_landable}", 'S', 'SEQUENCE')
      move_objects("#{@old_traffic}", "#{@new_traffic}", 'S', 'SEQUENCE')
    end

    desc "Move triggers to new db schema"
    task move_triggers: :environment do
      create_new_triggers("#{@new_landable}")
      drop_old_triggers("#{@old_landable}", "#{@new_landable}")
    end

  end

  def create_schema(schema)
    connection = ActiveRecord::Base.connection

    sql = %{
      CREATE SCHEMA #{schema};
    }
    puts "Creating #{schema} schema"
    connection.execute sql
  end

  def move_objects(from_schema, to_schema, relkind, object_type)
    connection = ActiveRecord::Base.connection

    # move objects from public to new schema
    objects = connection.select_all("
      SELECT o.relname
        FROM pg_class o
        JOIN pg_namespace n
        ON n.oid=o.relnamespace
        AND n.nspname = '#{from_schema}'
        AND o.relkind = '#{relkind}'
        ORDER BY o.relname
    ")

    objects.each do |object|
      sql = %{
        ALTER #{object_type} #{from_schema}.#{object['relname']}
          SET SCHEMA #{to_schema}
      }
      puts "Moving #{from_schema}.#{object['relname']} TO #{to_schema}"
      connection.execute sql
    end
  end

  def create_new_triggers(new_schema)
    puts "#{new_schema}"
    connection = ActiveRecord::Base.connection
    sql = %{
      CREATE FUNCTION #{new_schema}.pages_revision_ordinal()
        RETURNS TRIGGER
        AS
        $TRIGGER$
          BEGIN

          IF NEW.ordinal IS NOT NULL THEN
            RAISE EXCEPTION $$Must not supply ordinal value manually.$$;
          END IF;

          NEW.ordinal = (SELECT COALESCE(MAX(ordinal)+1,1)
                          FROM #{new_schema}.page_revisions
                          WHERE page_id = NEW.page_id);

          RETURN NEW;

          END
         $TRIGGER$
         LANGUAGE plpgsql;

      CREATE TRIGGER #{new_schema}_page_revisions__bfr_insert
        BEFORE INSERT ON #{new_schema}.page_revisions
        FOR EACH ROW EXECUTE PROCEDURE #{new_schema}.pages_revision_ordinal();

      CREATE FUNCTION #{new_schema}.tg_disallow()
        RETURNS TRIGGER
        AS
        $TRIGGER$
          BEGIN

          IF TG_LEVEL <> 'STATEMENT' THEN
            RAISE EXCEPTION $$You should use a statement-level trigger (trigger %, table %)$$, TG_NAME, TG_RELID::regclass;
          END IF;

          RAISE EXCEPTION $$%s are not allowed on table %$$, TG_OP, TG_RELNAME;

          RETURN NULL;

          END
         $TRIGGER$
         LANGUAGE plpgsql;

      CREATE TRIGGER #{new_schema}_page_revisions__no_delete
        BEFORE DELETE ON #{new_schema}.page_revisions
        FOR EACH STATEMENT EXECUTE PROCEDURE #{new_schema}.tg_disallow();

      CREATE TRIGGER #{new_schema}_page_revisions__no_update
        BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal ON #{new_schema}.page_revisions
        FOR EACH STATEMENT EXECUTE PROCEDURE #{new_schema}.tg_disallow();
    }
    puts "Creating new triggers..."
    connection.execute sql
  end

  def drop_old_triggers(old_schema, new_schema)
    connection = ActiveRecord::Base.connection
    sql = %{
      DROP TRIGGER IF EXISTS #{old_schema}_page_revisions__bfr_insert ON #{new_schema}.page_revisions;
      DROP TRIGGER IF EXISTS #{old_schema}_page_revisions__no_delete  ON #{new_schema}.page_revisions;
      DROP TRIGGER IF EXISTS #{old_schema}_page_revisions__no_update  ON #{new_schema}.page_revisions;

      DROP FUNCTION IF EXISTS #{old_schema}.pages_revision_ordinal();
      DROP FUNCTION IF EXISTS #{old_schema}.tg_disallow();
    }
    puts "Dropping old triggers..."
    connection.execute sql
  end
end