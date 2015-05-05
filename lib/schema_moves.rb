module SchemaMoves
  module Helpers
    def create_schema(schema)
      connection = ActiveRecord::Base.connection

      sql = %(
        CREATE SCHEMA #{schema};
            )
      puts "Creating #{schema} schema"
      connection.execute sql
    end

    def drop_schema(schema)
      connection = ActiveRecord::Base.connection

      sql = %(
        DROP SCHEMA #{schema};
            )
      puts "Dropping #{schema} schema"
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
        sql = %(
          ALTER #{object_type} #{from_schema}.#{object['relname']}
            SET SCHEMA #{to_schema}
                )
        puts "Moving #{from_schema}.#{object['relname']} TO #{to_schema}"
        connection.execute sql
      end
    end

    def create_new_triggers(new_schema)
      connection = ActiveRecord::Base.connection
      sql = %{
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

        CREATE FUNCTION #{new_schema}.template_revision_ordinal()
          RETURNS TRIGGER
          AS
          $TRIGGER$
            BEGIN

            IF NEW.ordinal IS NOT NULL THEN
              RAISE EXCEPTION $$Must not supply ordinal value manually.$$;
            END IF;

            NEW.ordinal = (SELECT COALESCE(MAX(ordinal)+1,1)
                            FROM #{new_schema}.template_revisions
                            WHERE template_id = NEW.template_id);

            RETURN NEW;

            END
           $TRIGGER$
           LANGUAGE plpgsql;

        CREATE TRIGGER #{new_schema}_template_revisions__bfr_insert
                  BEFORE INSERT ON #{new_schema}.template_revisions
                  FOR EACH ROW EXECUTE PROCEDURE #{new_schema}.template_revision_ordinal();

        CREATE TRIGGER #{new_schema}_template_revisions__no_delete
                BEFORE DELETE ON #{new_schema}.template_revisions
                FOR EACH STATEMENT EXECUTE PROCEDURE #{new_schema}.tg_disallow();

        CREATE TRIGGER #{new_schema}_template_revisions__no_update
                BEFORE UPDATE OF notes, is_minor, template_id, author_id, created_at, ordinal ON #{new_schema}.template_revisions
                FOR EACH STATEMENT EXECUTE PROCEDURE #{new_schema}.tg_disallow();

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

        CREATE TRIGGER #{new_schema}_page_revisions__no_delete
          BEFORE DELETE ON #{new_schema}.page_revisions
          FOR EACH STATEMENT EXECUTE PROCEDURE #{new_schema}.tg_disallow();

        CREATE TRIGGER #{new_schema}_page_revisions__no_update
          BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal ON #{new_schema}.page_revisions
          FOR EACH STATEMENT EXECUTE PROCEDURE #{new_schema}.tg_disallow();
      }
      puts 'Creating new triggers...'
      connection.execute sql
    end

    def drop_old_triggers(old_schema, new_schema)
      connection = ActiveRecord::Base.connection
      sql = %{
        DROP TRIGGER IF EXISTS #{old_schema}_page_revisions__bfr_insert ON #{new_schema}.page_revisions;
        DROP TRIGGER IF EXISTS #{old_schema}_page_revisions__no_delete  ON #{new_schema}.page_revisions;
        DROP TRIGGER IF EXISTS #{old_schema}_page_revisions__no_update  ON #{new_schema}.page_revisions;

        DROP TRIGGER IF EXISTS #{old_schema}_template_revisions__bfr_insert ON #{new_schema}.template_revisions;
        DROP TRIGGER IF EXISTS #{old_schema}_template_revisions__no_delete  ON #{new_schema}.template_revisions;
        DROP TRIGGER IF EXISTS #{old_schema}_template_revisions__no_update  ON #{new_schema}.template_revisions;

        DROP FUNCTION IF EXISTS #{old_schema}.pages_revision_ordinal();
        DROP FUNCTION IF EXISTS #{old_schema}.template_revision_ordinal();
        DROP FUNCTION IF EXISTS #{old_schema}.tg_disallow();
      }
      puts 'Dropping old triggers...'
      connection.execute sql
    end

    def ask(*args, &block)
      HighLine.new.ask(*args, &block)
    end

    def get_schema_names(new = true)
      # Always get old schemas
      @old_landable = ask('Enter the OLD main landable schema: ') { |q| q.default = 'landable' }
      @old_traffic = ask('Enter the OLD traffic schema: ') { |q| q.default = 'landable_traffic' }

      # Only ask for new names if new == true
      return unless new
      @new_landable = ask('Enter the NEW main landable schema: ') { |q| q.default = "#{appname}_landable" }
      @new_traffic = ask('Enter the NEW traffic schema: ') { |q| q.default = "#{appname}_landable_traffic" }
    end

    def create_schemas
      create_schema @new_landable
      create_schema @new_traffic
    end

    def migrate_objects
      # move_tables
      move_objects(@old_landable, @new_landable, 'r', 'TABLE')
      move_objects(@old_traffic, @new_traffic, 'r', 'TABLE')
      # move_sequences
      move_objects(@old_landable, @new_landable, 's', 'SEQUENCE')
      move_objects(@old_traffic, @new_traffic, 's', 'SEQUENCE')
      # move_views
      move_objects(@old_landable, @new_landable, 'v', 'TABLE')
      move_objects(@old_traffic, @new_traffic, 'v', 'TABLE')
      # move_triggers
      create_new_triggers(@new_landable)
      drop_old_triggers(@old_landable, @new_landable)
    end

    def drop_old_schemas
      drop_schema @old_landable
      drop_schema @old_traffic
    end

    def want_to_drop_old_schemas?
      drop = nil
      until %w(yes no).include?(drop.to_s.downcase)
        drop = ask('Would you like to drop the old schemas? (Yes or No)') { |q| q.default = 'no' }
      end
      drop.to_s.downcase == 'yes'
    end

    def appname
      Rails.application.class.parent_name.underscore
    end
  end
end
