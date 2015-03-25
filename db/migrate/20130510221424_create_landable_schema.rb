class CreateLandableSchema < Landable::Migration
  def change
    # This really should not be in this migration, but it's a convenient location
    # while everything's still under development.
    #
    # TODO extract to a separate migration, check if it exists, maybe check if we
    # actually have permission to do it, etc.
    execute 'CREATE EXTENSION "uuid-ossp";'
    enable_extension "uuid-ossp"
    enable_extension "hstore"
    enable_extension "pg_trgm"

    execute 'ALTER EXTENSION "uuid-ossp" SET SCHEMA "public";'
    execute "CREATE SCHEMA #{Landable.configuration.database_schema_prefix}landable;"


    ## status_codes

    create_table "#{Landable.configuration.database_schema_prefix}landable.status_code_categories", id: :uuid, primary_key: :status_code_category_id do |t|
      t.text      :name, null: false
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_status_code_categories__u_name ON #{Landable.configuration.database_schema_prefix}landable.status_code_categories(lower(name))"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.status_code_categories IS
              $$Categories that status codes belong to.  Used to affect behavior when viewing a page.$$"

    create_table "#{Landable.configuration.database_schema_prefix}landable.status_codes", id: :uuid, primary_key: :status_code_id do |t|
      t.uuid      :status_code_category_id, null: false
      t.integer   :code,                    null: false, limit: 2 # Creates as smallint
      t.text      :description,             null: false
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_status_codes__u_code ON #{Landable.configuration.database_schema_prefix}landable.status_codes(code)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.status_codes ADD CONSTRAINT status_code_category_fk FOREIGN KEY(status_code_category_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.status_code_categories(status_code_category_id)"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.status_codes IS
              $$Allowed status codes that pages can be set to.$$"


    ## themes

    create_table "#{Landable.configuration.database_schema_prefix}landable.themes", id: :uuid, primary_key: :theme_id do |t|
      t.text :name,           null: false
      t.text :body,           null: false
      t.text :description,    null: false
      t.text :thumbnail_url
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_themes__u_name ON #{Landable.configuration.database_schema_prefix}landable.themes(lower(name))"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.themes IS
              $$Created themes to be consumed by pages.  Themes supply formatting (css) rules and can supply header/footer content as well.$$"


    ## templates

    create_table "#{Landable.configuration.database_schema_prefix}landable.templates", id: :uuid, primary_key: :template_id do |t|
      t.text :name,           null: false
      t.text :slug,           null: false
      t.text :body,           null: false
      t.text :description,    null: false
      t.text :thumbnail_url
      t.boolean :is_layout,   null: false, default: false
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_templates__u_name ON #{Landable.configuration.database_schema_prefix}landable.templates(lower(name))"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.templates IS
              $$Created templates to be consumed by pages. 
              A template can supply 'starter' code for a page. 
              A template can also supply code to create elements on a page (sidebars, for example).$$"

    ## pages

    create_table "#{Landable.configuration.database_schema_prefix}landable.pages", id: :uuid, primary_key: :page_id do |t|
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

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_pages__u_path ON #{Landable.configuration.database_schema_prefix}landable.pages(lower(path))"
    execute "CREATE INDEX #{Landable.configuration.database_schema_prefix}landable_pages__trgm_path ON #{Landable.configuration.database_schema_prefix}landable.pages USING gin(path gin_trgm_ops)"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.pages IS
              $$Pages serve as a draft, where you can make changes, preview and save those changes without having to update the live page on the website.
              Pages also point to their published version, where applicable.$$"

    ## head_tags

    create_table "#{Landable.configuration.database_schema_prefix}landable.head_tags", id: :uuid, primary_key: :head_tag_id do |t|
      t.uuid :page_id
      t.text :content, null: false
      t.timestamps
    end

    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.head_tags ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.pages(page_id)"

    ## authors

    create_table "#{Landable.configuration.database_schema_prefix}landable.authors", id: :uuid, primary_key: :author_id do |t|
      t.text :email,      null: false
      t.text :username,   null: false
      t.text :first_name, null: false
      t.text :last_name,  null: false
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_authors__u_email ON #{Landable.configuration.database_schema_prefix}landable.authors(lower(email))"
    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_authors__u_username ON #{Landable.configuration.database_schema_prefix}landable.authors(username)"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.authors IS
              $$A list of authors that have accessed the website.  Feeds foreign keys so we know which authors have published pages and updated assets.$$"


    ## access_tokens

    create_table "#{Landable.configuration.database_schema_prefix}landable.access_tokens", id: :uuid, primary_key: :access_token_id do |t|
      t.uuid      :author_id,  null: false
      t.timestamp :expires_at, null: false
      t.timestamps
    end

    execute "CREATE INDEX #{Landable.configuration.database_schema_prefix}landable_access_tokens__author_id ON #{Landable.configuration.database_schema_prefix}landable.access_tokens(author_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.access_tokens ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.authors(author_id)"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.access_tokens IS
              $$Access tokens provide authentication information for specific users.$$"


    ## page_revisions

    create_table "#{Landable.configuration.database_schema_prefix}landable.page_revisions", id: :uuid, primary_key: :page_revision_id do |t|
      t.integer   :ordinal
      t.text      :notes
      t.boolean   :is_minor,      default: false
      t.boolean   :is_published,  default: true

      t.uuid      :page_id,   null: false
      t.uuid      :author_id, null: false

      t.text      :snapshot_attributes, null: false

      t.timestamps
    end

    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.page_revisions IS
              $$Page revisions serve as a historical reference to pages as they were published.
              The attributes of the page at the time of publishing are stored in snapshot_attributes, as essentially a text representation of a hash.
              The current/active/live revision can be identified by referring to its corresponding PAGES record, OR by looking for the max(ordinal) for a given page_id.$$"


    ## categories

    create_table "#{Landable.configuration.database_schema_prefix}landable.categories", id: :uuid, primary_key: :category_id do |t|
      t.text      :name
      t.text      :description
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_categories__u_name ON #{Landable.configuration.database_schema_prefix}landable.categories(lower(name))"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.categories IS
              $$Categories are used to sort pages.
              Examples could include SEO, PPC.$$"


    ## assets

    create_table "#{Landable.configuration.database_schema_prefix}landable.assets", id: :uuid, primary_key: :asset_id do |t|
      t.uuid    :author_id,   null: false
      t.text    :name,        null: false
      t.text    :description
      t.text    :data,        null: false
      t.text    :md5sum,      null: false, length: 32
      t.text    :mime_type,   null: false
      t.integer :file_size
      t.timestamps
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_assets__u_lower_name ON #{Landable.configuration.database_schema_prefix}landable.assets(lower(name))"
    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_assets__u_data ON #{Landable.configuration.database_schema_prefix}landable.assets(data)"
    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_assets__u_md5sum ON #{Landable.configuration.database_schema_prefix}landable.assets(md5sum)"
    execute "CREATE INDEX #{Landable.configuration.database_schema_prefix}landable_assets__author_id ON #{Landable.configuration.database_schema_prefix}landable.assets(author_id)"

    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.assets ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.authors(author_id)"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.assets IS
              $$List of all assets uploaded.
              Examples of assets include images (jpg, png, gif) and documents (PDF).
              data, md5sum, mime_type, file_size are populated via the rails gem CarrierWave when a record is created.$$"


    ## browsers

    create_table "#{Landable.configuration.database_schema_prefix}landable.browsers", id: :uuid, primary_key: :browser_id do |t|
      t.text :device
      t.text :os,                   null: false
      t.text :os_version,           null: false
      t.text :browser
      t.text :browser_version

      t.boolean :screenshots_supported, null: false, default: false
      t.boolean :is_primary,            null: false, default: false

      t.timestamps
    end

    execute "CREATE INDEX #{Landable.configuration.database_schema_prefix}landable_screenshots__device_browser_browser_version ON #{Landable.configuration.database_schema_prefix}landable.browsers(device, browser, browser_version)"


    ## screenshots

    create_table "#{Landable.configuration.database_schema_prefix}landable.screenshots", id: :uuid, primary_key: :screenshot_id do |t|
      t.uuid :screenshotable_id,    null: false
      t.text :screenshotable_type,  null: false

      t.uuid :browser_id

      t.text :state
      t.text :thumb_url
      t.text :image_url

      t.text :browserstack_id
      t.text :browserstack_job_id

      t.timestamps
    end

    execute "CREATE INDEX #{Landable.configuration.database_schema_prefix}landable_screenshots__screenshotable_id_screenshotable_type_state ON #{Landable.configuration.database_schema_prefix}landable.screenshots(screenshotable_id, screenshotable_type, state)"
    execute "CREATE INDEX #{Landable.configuration.database_schema_prefix}landable_screenshots__state ON #{Landable.configuration.database_schema_prefix}landable.screenshots(state)"
    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_screenshots__u_browserstack_id ON #{Landable.configuration.database_schema_prefix}landable.screenshots(browserstack_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.screenshots ADD CONSTRAINT browser_id_fk FOREIGN KEY (browser_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.browsers(browser_id)"
    execute "COMMENT ON TABLE #{Landable.configuration.database_schema_prefix}landable.screenshots IS
              $$Stores saved screenshots (taken of pages) and the URLs to retrieve the actual image.$$"


    ## asset associations table

    create_table "#{Landable.configuration.database_schema_prefix}landable.page_assets", id: :uuid, primary_key: :page_asset_id do |t|
      t.uuid :page_id,    null: false
      t.uuid :asset_id,         null: false
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_page_assets__u_page_id_asset_id ON #{Landable.configuration.database_schema_prefix}landable.page_assets (page_id, asset_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_assets ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.pages(page_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_assets ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.assets(asset_id)"

    create_table "#{Landable.configuration.database_schema_prefix}landable.page_revision_assets", id: :uuid, primary_key: :page_revision_asset_id do |t|
      t.uuid :page_revision_id,    null: false
      t.uuid :asset_id,         null: false
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_page_revision_assets__u_page_revision_id_asset_id ON #{Landable.configuration.database_schema_prefix}landable.page_revision_assets (page_revision_id, asset_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_revision_assets ADD CONSTRAINT page_revision_id_fk FOREIGN KEY (page_revision_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.page_revisions(page_revision_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_revision_assets ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.assets(asset_id)"

    create_table "#{Landable.configuration.database_schema_prefix}landable.theme_assets", id: :uuid, primary_key: :theme_asset_id do |t|
      t.uuid :theme_id,    null: false
      t.uuid :asset_id,         null: false
    end

    execute "CREATE UNIQUE INDEX #{Landable.configuration.database_schema_prefix}landable_theme_assets__u_theme_id_asset_id ON #{Landable.configuration.database_schema_prefix}landable.theme_assets (theme_id, asset_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.theme_assets ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.themes(theme_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.theme_assets ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.assets(asset_id)"

    ## other stuff

    # Constraints for page_revisions
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_revisions ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.pages(page_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.page_revisions ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.authors(author_id)"

    # Constraints for pages
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.pages ADD CONSTRAINT revision_id_fk FOREIGN KEY (published_revision_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.page_revisions(page_revision_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.pages ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.themes(theme_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.pages ADD CONSTRAINT category_id_fk FOREIGN KEY (category_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.categories(category_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.pages ADD CONSTRAINT status_code_fk FOREIGN KEY (status_code_id) REFERENCES #{Landable.configuration.database_schema_prefix}landable.status_codes(status_code_id)"
    execute "ALTER TABLE #{Landable.configuration.database_schema_prefix}landable.pages ADD CONSTRAINT only_valid_paths CHECK (path ~ '^/[a-zA-Z0-9/_.~-]*$');"

    # Revision-tracking trigger to automatically update ordinal
    execute "CREATE FUNCTION #{Landable.configuration.database_schema_prefix}landable.pages_revision_ordinal()
      RETURNS TRIGGER
      AS
      $TRIGGER$
        BEGIN

        IF NEW.ordinal IS NOT NULL THEN
          RAISE EXCEPTION $$Must not supply ordinal value manually.$$;
        END IF;

        NEW.ordinal = (SELECT COALESCE(MAX(ordinal)+1,1)
                        FROM #{Landable.configuration.database_schema_prefix}landable.page_revisions
                        WHERE page_id = NEW.page_id);

        RETURN NEW;

        END
       $TRIGGER$
       LANGUAGE plpgsql;"

      execute "CREATE TRIGGER #{Landable.configuration.database_schema_prefix}landable_page_revisions__bfr_insert
              BEFORE INSERT ON #{Landable.configuration.database_schema_prefix}landable.page_revisions
              FOR EACH ROW EXECUTE PROCEDURE #{Landable.configuration.database_schema_prefix}landable.pages_revision_ordinal();"

    # Trigger disallowing deletes on page_revisions
    execute "CREATE FUNCTION #{Landable.configuration.database_schema_prefix}landable.tg_disallow()
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

      execute "CREATE TRIGGER #{Landable.configuration.database_schema_prefix}landable_page_revisions__no_delete
              BEFORE DELETE ON #{Landable.configuration.database_schema_prefix}landable.page_revisions
              FOR EACH STATEMENT EXECUTE PROCEDURE #{Landable.configuration.database_schema_prefix}landable.tg_disallow();"

      execute "CREATE TRIGGER #{Landable.configuration.database_schema_prefix}landable_page_revisions__no_update
              BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal ON #{Landable.configuration.database_schema_prefix}landable.page_revisions
              FOR EACH STATEMENT EXECUTE PROCEDURE #{Landable.configuration.database_schema_prefix}landable.tg_disallow();"

  end
end
