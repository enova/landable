class CreateLandableSchema < ActiveRecord::Migration
  def change
    # This really should not be in this migration, but it's a convenient location
    # while everything's still under development.
    #
    # TODO extract to a separate migration, check if it exists, maybe check if we
    # actually have permission to do it, etc.
    enable_extension "uuid-ossp"
    enable_extension "hstore"
    enable_extension "pg_trgm"

    execute "CREATE SCHEMA landable;"

    create_table 'landable.status_code_categories', id: :uuid, primary_key: :status_code_category_id do |t|
      t.text      :name, null: false
    end

    execute "CREATE UNIQUE INDEX landable_status_code_categories__u_name ON landable.status_code_categories(lower(name))"

    execute "INSERT INTO landable.status_code_categories (name) VALUES
              ('okay')
            , ('redirect')
            , ('missing')"

    create_table 'landable.status_codes', id: :uuid, primary_key: :status_code_id do |t|
      t.uuid      :status_code_category_id, null: false
      t.integer   :code,        null: false
      t.text      :description, null: false
    end

    execute "CREATE UNIQUE INDEX landable_status_codes__u_code ON landable.status_codes(code)"
    execute "ALTER TABLE landable.status_codes ADD CONSTRAINT status_code_category_fk FOREIGN KEY(status_code_category_id) REFERENCES landable.status_code_categories(status_code_category_id)"

    execute "INSERT INTO landable.status_codes(status_code_category_id, code, description)
              SELECT status_code_category_id, 200, 'OK' FROM landable.status_code_categories WHERE name = 'okay';
            INSERT INTO landable.status_codes(status_code_category_id, code, description)
              SELECT status_code_category_id, 301, 'Permanent Redirect' FROM landable.status_code_categories WHERE name = 'redirect';
            INSERT INTO landable.status_codes(status_code_category_id, code, description)
              SELECT status_code_category_id, 302, 'Temporary Redirect' FROM landable.status_code_categories WHERE name = 'redirect';
            INSERT INTO landable.status_codes(status_code_category_id, code, description)
              SELECT status_code_category_id, 404, 'Not Found' FROM landable.status_code_categories WHERE name = 'missing';"

    create_table 'landable.themes', id: :uuid, primary_key: :theme_id do |t|
      t.text :name,           null: false
      t.text :body,           null: false
      t.text :description,    null: false
      t.text :thumbnail_url
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX landable_themes__u_name ON landable.themes(lower(name))"

    create_table 'landable.templates', id: :uuid, primary_key: :template_id do |t|
      t.text :name,           null: false
      t.text :body
      t.text :description,    null: false
      t.text :thumbnail_url
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX landable_templates__u_name ON landable.templates(lower(name))"

    create_table 'landable.pages', id: :uuid, primary_key: :page_id do |t|
      t.uuid      :published_revision_id
      t.boolean   :is_publishable, null: false, default: true

      t.uuid      :theme_id
      t.uuid      :category_id
      t.uuid      :status_code_id, null: false

      t.text      :path, null: false

      t.text      :title
      t.text      :body

      t.text      :redirect_url

      t.hstore    :meta_tags

      t.timestamp :imported_at
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX landable_pages__u_path ON landable.pages(lower(path))"
    execute "CREATE INDEX landable_pages__trgm_path ON landable.pages USING gin(path gin_trgm_ops)"

    create_table 'landable.authors', id: :uuid, primary_key: :author_id do |t|
      t.text :email,      null: false
      t.text :username,   null: false
      t.text :first_name, null: false
      t.text :last_name,  null: false
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX landable_authors__u_email ON landable.authors(lower(email))"
    execute "CREATE UNIQUE INDEX landable_authors__u_username ON landable.authors(username)"

    create_table 'landable.access_tokens', id: :uuid, primary_key: :access_token_id do |t|
      t.uuid      :author_id,  null: false
      t.timestamp :expires_at, null: false
      t.timestamps
    end

    execute "CREATE INDEX landable_access_tokens__author_id ON landable.access_tokens(author_id)"
    execute "ALTER TABLE landable.access_tokens ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES landable.authors(author_id)"

    create_table 'landable.page_revisions', id: :uuid, primary_key: :page_revision_id do |t|
      t.integer   :ordinal
      t.text      :notes
      t.boolean   :is_minor,      default: false
      t.boolean   :is_published,  default: true

      t.uuid      :page_id,   null: false
      t.uuid      :author_id, null: false
      t.uuid      :theme_id

      t.text      :snapshot_attributes, null: false

      t.timestamps
    end

    create_table 'landable.categories', id: :uuid, primary_key: :category_id do |t|
      t.text      :name
      t.text      :description
    end

    execute "CREATE UNIQUE INDEX landable_categories__u_name ON landable.categories(lower(name))"

    create_table 'landable.assets', id: :uuid, primary_key: :asset_id do |t|
      t.uuid    :author_id,   null: false
      t.text    :name,        null: false
      t.text    :description
      t.text    :data,        null: false
      t.text    :md5sum,      null: false, length: 32
      t.text    :mime_type,   null: false
      t.text    :basename,    null: false
      t.integer :file_size
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX landable_assets__u_lower_name ON landable.assets(lower(name))"
    execute "CREATE UNIQUE INDEX landable_assets__u_data ON landable.assets(data)"
    execute "CREATE UNIQUE INDEX landable_assets__u_md5sum ON landable.assets(md5sum)"
    execute "CREATE INDEX landable_assets__author_id ON landable.assets(author_id)"

    execute "ALTER TABLE landable.assets ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES landable.authors(author_id)"

    create_table 'landable.page_assets', id: :uuid, primary_key: :page_asset_id do |t|
      t.uuid :asset_id, null: false
      t.uuid :page_id,  null: false
      t.text :alias
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX landable_page_assets__u_page_id_asset_id ON landable.page_assets(page_id, asset_id)"
    execute "ALTER TABLE landable.page_assets ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES landable.assets(asset_id)"
    execute "ALTER TABLE landable.page_assets ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES landable.pages(page_id)"

    create_table 'landable.theme_assets', id: :uuid, primary_key: :theme_asset_id do |t|
      t.uuid :asset_id, null: false
      t.uuid :theme_id, null: false
      t.text :alias
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX landable_theme_assets__u_theme_id_asset_id ON landable.theme_assets(theme_id, asset_id)"
    execute "ALTER TABLE landable.theme_assets ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES landable.assets(asset_id)"
    execute "ALTER TABLE landable.theme_assets ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES landable.themes(theme_id)"

    create_table 'landable.page_revision_assets', id: :uuid, primary_key: :page_revision_asset_id do |t|
      t.uuid :asset_id,         null: false
      t.uuid :page_revision_id, null: false
      t.text :alias
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX landable_page_revision_assets__u_page_revision_id_asset_id ON landable.page_revision_assets(page_revision_id, asset_id)"
    execute "ALTER TABLE landable.page_revision_assets ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES landable.assets(asset_id)"
    execute "ALTER TABLE landable.page_revision_assets ADD CONSTRAINT page_revision_id_fk FOREIGN KEY (page_revision_id) REFERENCES landable.page_revisions(page_revision_id)"

    # Constraints for page_revisions
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES landable.pages(page_id)"
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES landable.authors(author_id)"
    execute "ALTER TABLE landable.page_revisions ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES landable.themes(theme_id)"

    # Constraints for pages
    execute "ALTER TABLE landable.pages ADD CONSTRAINT revision_id_fk FOREIGN KEY (published_revision_id) REFERENCES landable.page_revisions(page_revision_id)"
    execute "ALTER TABLE landable.pages ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES landable.themes(theme_id)"
    execute "ALTER TABLE landable.pages ADD CONSTRAINT category_id_fk FOREIGN KEY (category_id) REFERENCES landable.categories(category_id)"
    execute "ALTER TABLE landable.pages ADD CONSTRAINT status_code_fk FOREIGN KEY (status_code_id) REFERENCES landable.status_codes(status_code_id)"
    execute "ALTER TABLE landable.pages ADD CONSTRAINT only_valid_paths CHECK (path ~ '^/[a-zA-Z0-9/_.~-]*$');"

    # Revision-tracking trigger to automatically update ordinal
    execute "CREATE FUNCTION landable.pages_revision_ordinal()
      RETURNS TRIGGER
      AS
      $TRIGGER$
        BEGIN

        IF NEW.ordinal IS NOT NULL THEN
          RAISE EXCEPTION $$Must not supply ordinal value manually.$$;
        END IF;

        NEW.ordinal = (SELECT COALESCE(MAX(ordinal)+1,1)
                        FROM landable.page_revisions
                        WHERE page_id = NEW.page_id);

        RETURN NEW;

        END
       $TRIGGER$
       LANGUAGE plpgsql;"

      execute "CREATE TRIGGER landable_page_revisions__bfr_insert
              BEFORE INSERT ON landable.page_revisions
              FOR EACH ROW EXECUTE PROCEDURE landable.pages_revision_ordinal();"

    # Trigger disallowing deletes on page_revisions
    execute "CREATE FUNCTION landable.tg_disallow()
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

      execute "CREATE TRIGGER landable_page_revisions__no_delete
              BEFORE DELETE ON landable.page_revisions
              FOR EACH STATEMENT EXECUTE PROCEDURE landable.tg_disallow();"

      execute "CREATE TRIGGER landable_page_revisions__no_update
              BEFORE UPDATE OF notes, is_minor, page_id, author_id, theme_id, created_at, ordinal ON landable.page_revisions
              FOR EACH STATEMENT EXECUTE PROCEDURE landable.tg_disallow();"

  end
end
