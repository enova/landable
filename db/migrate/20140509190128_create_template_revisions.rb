class CreateTemplateRevisions < ActiveRecord::Migration
  def change
    create_table "#{Landable.configuration.database_schema_prefix}landable.template_revisions", id: :uuid, primary_key: :template_revision_id do |t|
      t.integer   :ordinal
      t.text      :notes
      t.boolean   :is_minor,      default: false
      t.boolean   :is_published,  default: true

      t.uuid      :template_id,   null: false
      t.uuid      :author_id,     null: false

      t.text      :name
      t.text      :slug
      t.text      :body
      t.text      :description

      t.timestamps
    end

    add_column "#{Landable.configuration.database_schema_prefix}landable.templates", :published_revision_id, :uuid
    add_column "#{Landable.configuration.database_schema_prefix}landable.templates", :is_publishable, :boolean, null: :false, default: true

    # Create foreign keys
    execute <<-SQL
      ALTER TABLE #{Landable::Template.table_name}
        ADD CONSTRAINT template_revision_id_fk
        FOREIGN KEY (published_revision_id)
        REFERENCES #{Landable::TemplateRevision.table_name} (template_revision_id);

      ALTER TABLE #{Landable::TemplateRevision.table_name}
        ADD CONSTRAINT template_id_fk
        FOREIGN KEY (template_id)
        REFERENCES #{Landable::Template.table_name} (template_id);

      ALTER TABLE #{Landable::TemplateRevision.table_name}
        ADD CONSTRAINT author_id_fk
        FOREIGN KEY (author_id)
        REFERENCES #{Landable::Author.table_name} (author_id);
    SQL

    # Revision-tracking trigger to automatically update ordinal
    execute "CREATE FUNCTION #{Landable.configuration.database_schema_prefix}landable.template_revision_ordinal()
      RETURNS TRIGGER
      AS
      $TRIGGER$
        BEGIN

        IF NEW.ordinal IS NOT NULL THEN
          RAISE EXCEPTION $$Must not supply ordinal value manually.$$;
        END IF;

        NEW.ordinal = (SELECT COALESCE(MAX(ordinal)+1,1)
                        FROM #{Landable.configuration.database_schema_prefix}landable.template_revisions
                        WHERE template_id = NEW.template_id);

        RETURN NEW;

        END
       $TRIGGER$
       LANGUAGE plpgsql;"

      execute "CREATE TRIGGER #{Landable.configuration.database_schema_prefix}landable_template_revisions__bfr_insert
              BEFORE INSERT ON #{Landable.configuration.database_schema_prefix}landable.template_revisions
              FOR EACH ROW EXECUTE PROCEDURE #{Landable.configuration.database_schema_prefix}landable.template_revision_ordinal();"

    # Trigger disallowing deletes on template_revisions
    execute "CREATE TRIGGER #{Landable.configuration.database_schema_prefix}landable_template_revisions__no_delete
            BEFORE DELETE ON #{Landable.configuration.database_schema_prefix}landable.template_revisions
            FOR EACH STATEMENT EXECUTE PROCEDURE #{Landable.configuration.database_schema_prefix}landable.tg_disallow();"

    execute "CREATE TRIGGER #{Landable.configuration.database_schema_prefix}landable_template_revisions__no_update
            BEFORE UPDATE OF notes, is_minor, template_id, author_id, created_at, ordinal ON #{Landable.configuration.database_schema_prefix}landable.template_revisions
            FOR EACH STATEMENT EXECUTE PROCEDURE #{Landable.configuration.database_schema_prefix}landable.tg_disallow();"


  end
end
