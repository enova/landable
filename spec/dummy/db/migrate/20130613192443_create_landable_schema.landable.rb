# This migration comes from landable (originally 20130510221424)
class CreateLandableSchema < ActiveRecord::Migration
  def change
    # This really should not be in this migration, but it's a convenient location
    # while everything's still under development.
    #
    # TODO extract to a separate migration, check if it exists, maybe check if we
    # actually have permission to do it, etc.
    enable_extension "uuid-ossp"
    enable_extension "hstore"

    # Currently prevents creation of Pages due to apparent AR4 bug:
    # execute " DROP DOMAIN IF EXISTS uri;
    #           CREATE DOMAIN uri AS TEXT
    #           CHECK(
    #             VALUE ~ '^/[a-zA-Z0-9/_.~-]*$'
    #           );"

    execute "DROP SCHEMA IF EXISTS landable; CREATE SCHEMA landable;"

    create_table 'landable.themes', id: :uuid, primary_key: :theme_id do |t|
      t.text :name,           null: false
      t.text :body,           null: false
      t.text :description,    null: false
      t.text :screenshot_url
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX theme_name_lower ON landable.themes(lower(name))"

    create_table 'landable.pages', id: :uuid, primary_key: :page_id do |t|
      t.uuid      :published_revision_id
      t.boolean   :is_publishable, null: false, default: true

      t.uuid      :theme_id
      t.uuid      :category_id

      t.text      :path, null: false

      t.text      :title
      t.text      :body

      t.integer   :status_code, null: false, default: 200
      t.text      :redirect_url

      t.hstore    :meta_tags

      t.timestamp :imported_at
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX pages_path_lower ON landable.pages(lower(path))"

    create_table 'landable.authors', id: :uuid, primary_key: :author_id do |t|
      t.text :email,      null: false
      t.text :username,   null: false
      t.text :first_name, null: false
      t.text :last_name,  null: false
      t.timestamps
    end

    add_index 'landable.authors', :email, unique: true
    add_index 'landable.authors', :username, unique: true

    create_table 'landable.access_tokens', id: :uuid, primary_key: :access_token_id do |t|
      t.uuid      :author_id,  null: false
      t.timestamp :expires_at, null: false
      t.timestamps
    end

    add_index 'landable.access_tokens', :author_id

    create_table 'landable.page_revisions', id: :uuid, primary_key: :page_revision_id do |t|
      t.integer   :ordinal
      t.text      :notes
      t.boolean   :is_minor,  default: false

      t.uuid      :page_id,   null: false
      t.uuid      :author_id, null: false
      t.uuid      :theme_id

      t.hstore    :snapshot_attributes, null: false

      t.timestamps
    end

    create_table 'landable.categories', id: :uuid, primary_key: :category_id do |t|
      t.text      :name
      t.text      :description
    end

    execute "CREATE UNIQUE INDEX category_name_lower ON landable.categories(lower(name))"

    create_table 'landable.assets', id: :uuid, primary_key: :asset_id do |t|
      t.uuid :author_id, null: false
      t.text :name,      null: false
      t.text :sha,       null: false, length: 64
      t.text :mime_type, null: false
      t.text :basename,  null: false
      t.text :content,   null: false
    end

    add_index 'landable.assets', :content, unique: true
    add_index 'landable.assets', :sha,     unique: true
    execute "ALTER TABLE landable.assets ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES landable.authors(author_id)"

    # Constraints for page_revisions
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES landable.pages(page_id)"
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES landable.authors(author_id)"
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES landable.themes(theme_id)"

    # Constraints for pages
    execute "ALTER TABLE landable.pages ADD CONSTRAINT revision_id_fk FOREIGN KEY (published_revision_id) REFERENCES landable.page_revisions(page_revision_id)"
    execute "ALTER TABLE landable.pages ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES landable.themes(theme_id)"
    execute "ALTER TABLE landable.pages ADD CONSTRAINT category_id_fk FOREIGN KEY (category_id) REFERENCES landable.categories(category_id)"
    execute "ALTER TABLE landable.pages ADD CONSTRAINT only_valid_paths CHECK (path ~ '^/[a-zA-Z0-9/_.~-]*$');"
    execute "ALTER TABLE landable.pages ADD CONSTRAINT only_valid_status_codes CHECK (status_code IN (200,301,302,404))"

    # Revision-tracking trigger to automatically update ordinal
    execute "CREATE FUNCTION pages_revision_ordinal()
      RETURNS TRIGGER
      AS
      $TRIGGER$
        BEGIN

        NEW.ordinal = (SELECT COALESCE(MAX(ordinal)+1,1)
                        FROM landable.page_revisions
                        WHERE page_id = NEW.page_id);

        RETURN NEW;

        END
       $TRIGGER$
       LANGUAGE plpgsql;"

      execute "CREATE TRIGGER page_revivions_bfr_insert
              BEFORE INSERT ON landable.page_revisions
              FOR EACH ROW EXECUTE PROCEDURE pages_revision_ordinal();"

    # Trigger disallowing deletes on page_revisions
    execute "CREATE FUNCTION tg_disallow()
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
       LANGUAGE plpgsql;"

      execute "CREATE TRIGGER page_revivions_no_delete
              BEFORE DELETE ON landable.page_revisions
              FOR EACH STATEMENT EXECUTE PROCEDURE tg_disallow();"

  end
end
