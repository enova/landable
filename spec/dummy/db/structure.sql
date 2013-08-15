--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: landable; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA landable;


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: hstore; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA public;


--
-- Name: EXTENSION hstore; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION hstore IS 'data type for storing sets of (key, value) pairs';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = landable, pg_catalog;

--
-- Name: pages_revision_ordinal(); Type: FUNCTION; Schema: landable; Owner: -
--

CREATE FUNCTION pages_revision_ordinal() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
        BEGIN

        IF NEW.ordinal IS NOT NULL THEN
          RAISE EXCEPTION $$Must not supply ordinal value manually.$$;
        END IF;

        NEW.ordinal = (SELECT COALESCE(MAX(ordinal)+1,1)
                        FROM landable.page_revisions
                        WHERE page_id = NEW.page_id);

        RETURN NEW;

        END
       $_$;


--
-- Name: tg_disallow(); Type: FUNCTION; Schema: landable; Owner: -
--

CREATE FUNCTION tg_disallow() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
        BEGIN

        IF TG_LEVEL <> 'STATEMENT' THEN
          RAISE EXCEPTION $$You should use a statement-level trigger (trigger %, table %)$$, TG_NAME, TG_RELID::regclass;
        END IF;

        RAISE EXCEPTION $$%s are not allowed on table %$$, TG_OP, TG_RELNAME;

        RETURN NULL;

        END
       $_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: access_tokens; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE access_tokens (
    access_token_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    author_id uuid NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: TABLE access_tokens; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE access_tokens IS 'Access tokens provide authentication information for specific users.';


--
-- Name: assets; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE assets (
    asset_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    author_id uuid NOT NULL,
    name text NOT NULL,
    description text,
    data text NOT NULL,
    md5sum text NOT NULL,
    mime_type text NOT NULL,
    basename text NOT NULL,
    file_size integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: TABLE assets; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE assets IS 'List of all assets uploaded.
              Examples of assets include images (jpg, png, gif) and documents (PDF).
              data, md5sum, mime_type, basename, file_size are populated via the rails gem CarrierWave when a record is created.';


--
-- Name: authors; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE authors (
    author_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    email text NOT NULL,
    username text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: TABLE authors; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE authors IS 'A list of authors that have accessed the website.  Feeds foreign keys so we know which authors have published pages and updated assets.';


--
-- Name: categories; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    category_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text,
    description text
);


--
-- Name: TABLE categories; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE categories IS 'Categories are used to sort pages.
              Examples could include SEO, PPC.';


--
-- Name: page_assets; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE page_assets (
    page_asset_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    page_id uuid NOT NULL,
    asset_id uuid NOT NULL
);


--
-- Name: page_revision_assets; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE page_revision_assets (
    page_revision_asset_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    page_revision_id uuid NOT NULL,
    asset_id uuid NOT NULL
);


--
-- Name: page_revisions; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE page_revisions (
    page_revision_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    ordinal integer,
    notes text,
    is_minor boolean DEFAULT false,
    is_published boolean DEFAULT true,
    page_id uuid NOT NULL,
    author_id uuid NOT NULL,
    snapshot_attributes text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: TABLE page_revisions; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE page_revisions IS 'Page revisions serve as a historical reference to pages as they were published.
              The attributes of the page at the time of publishing are stored in snapshot_attributes, as essentially a text representation of a hash.
              The current/active/live revision can be identified by referring to its corresponding PAGES record, OR by looking for the max(ordinal) for a given page_id.';


--
-- Name: pages; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    page_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    published_revision_id uuid,
    is_publishable boolean DEFAULT true NOT NULL,
    theme_id uuid,
    category_id uuid,
    status_code_id uuid NOT NULL,
    path text NOT NULL,
    title text,
    body text,
    redirect_url text,
    meta_tags public.hstore,
    imported_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT only_valid_paths CHECK ((path ~ '^/[a-zA-Z0-9/_.~-]*$'::text))
);


--
-- Name: TABLE pages; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE pages IS 'Pages serve as a draft, where you can make changes, preview and save those changes without having to update the live page on the website.
              Pages also point to their published version, where applicable.';


--
-- Name: screenshots; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE screenshots (
    screenshot_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    screenshotable_id uuid NOT NULL,
    screenshotable_type text NOT NULL,
    device text,
    os text,
    os_version text,
    browser text,
    browser_version text,
    state text,
    thumb_url text,
    image_url text,
    browserstack_id text,
    browserstack_job_id text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: TABLE screenshots; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE screenshots IS 'Stores saved screenshots (taken of pages) and the URLs to retrieve the actual image.';


--
-- Name: status_code_categories; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE status_code_categories (
    status_code_category_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL
);


--
-- Name: TABLE status_code_categories; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE status_code_categories IS 'Categories that status codes belong to.  Used to affect behavior when viewing a page.';


--
-- Name: status_codes; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE status_codes (
    status_code_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    status_code_category_id uuid NOT NULL,
    code smallint NOT NULL,
    description text NOT NULL
);


--
-- Name: TABLE status_codes; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE status_codes IS 'Allowed status codes that pages can be set to.';


--
-- Name: templates; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE templates (
    template_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    slug text NOT NULL,
    body text NOT NULL,
    description text NOT NULL,
    thumbnail_url text,
    is_layout boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: TABLE templates; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE templates IS 'Created templates to be consumed by pages. 
              A template can supply ''starter'' code for a page. 
              A template can also supply code to create elements on a page (sidebars, for example).';


--
-- Name: theme_assets; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE theme_assets (
    theme_asset_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    theme_id uuid NOT NULL,
    asset_id uuid NOT NULL
);


--
-- Name: themes; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE themes (
    theme_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    body text NOT NULL,
    description text NOT NULL,
    thumbnail_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: TABLE themes; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE themes IS 'Created themes to be consumed by pages.  Themes supply formatting (css) rules and can supply header/footer content as well.';


SET search_path = public, pg_catalog;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


SET search_path = landable, pg_catalog;

--
-- Name: access_tokens_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (access_token_id);


--
-- Name: assets_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assets
    ADD CONSTRAINT assets_pkey PRIMARY KEY (asset_id);


--
-- Name: authors_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (author_id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (category_id);


--
-- Name: page_assets_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY page_assets
    ADD CONSTRAINT page_assets_pkey PRIMARY KEY (page_asset_id);


--
-- Name: page_revision_assets_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY page_revision_assets
    ADD CONSTRAINT page_revision_assets_pkey PRIMARY KEY (page_revision_asset_id);


--
-- Name: page_revisions_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY page_revisions
    ADD CONSTRAINT page_revisions_pkey PRIMARY KEY (page_revision_id);


--
-- Name: pages_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT pages_pkey PRIMARY KEY (page_id);


--
-- Name: screenshots_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY screenshots
    ADD CONSTRAINT screenshots_pkey PRIMARY KEY (screenshot_id);


--
-- Name: status_code_categories_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY status_code_categories
    ADD CONSTRAINT status_code_categories_pkey PRIMARY KEY (status_code_category_id);


--
-- Name: status_codes_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY status_codes
    ADD CONSTRAINT status_codes_pkey PRIMARY KEY (status_code_id);


--
-- Name: templates_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY templates
    ADD CONSTRAINT templates_pkey PRIMARY KEY (template_id);


--
-- Name: theme_assets_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY theme_assets
    ADD CONSTRAINT theme_assets_pkey PRIMARY KEY (theme_asset_id);


--
-- Name: themes_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY themes
    ADD CONSTRAINT themes_pkey PRIMARY KEY (theme_id);


--
-- Name: landable_access_tokens__author_id; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE INDEX landable_access_tokens__author_id ON access_tokens USING btree (author_id);


--
-- Name: landable_assets__author_id; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE INDEX landable_assets__author_id ON assets USING btree (author_id);


--
-- Name: landable_assets__u_data; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_assets__u_data ON assets USING btree (data);


--
-- Name: landable_assets__u_lower_name; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_assets__u_lower_name ON assets USING btree (lower(name));


--
-- Name: landable_assets__u_md5sum; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_assets__u_md5sum ON assets USING btree (md5sum);


--
-- Name: landable_authors__u_email; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_authors__u_email ON authors USING btree (lower(email));


--
-- Name: landable_authors__u_username; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_authors__u_username ON authors USING btree (username);


--
-- Name: landable_categories__u_name; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_categories__u_name ON categories USING btree (lower(name));


--
-- Name: landable_page_assets__u_page_id_asset_id; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_page_assets__u_page_id_asset_id ON page_assets USING btree (page_id, asset_id);


--
-- Name: landable_page_revision_assets__u_page_revision_id_asset_id; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_page_revision_assets__u_page_revision_id_asset_id ON page_revision_assets USING btree (page_revision_id, asset_id);


--
-- Name: landable_pages__trgm_path; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE INDEX landable_pages__trgm_path ON pages USING gin (path public.gin_trgm_ops);


--
-- Name: landable_pages__u_path; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_pages__u_path ON pages USING btree (lower(path));


--
-- Name: landable_screenshots__screenshotable_id_screenshotable_type; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE INDEX landable_screenshots__screenshotable_id_screenshotable_type ON screenshots USING btree (screenshotable_id, screenshotable_type);


--
-- Name: landable_screenshots__u_browserstack_id; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_screenshots__u_browserstack_id ON screenshots USING btree (browserstack_id);


--
-- Name: landable_status_code_categories__u_name; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_status_code_categories__u_name ON status_code_categories USING btree (lower(name));


--
-- Name: landable_status_codes__u_code; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_status_codes__u_code ON status_codes USING btree (code);


--
-- Name: landable_templates__u_name; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_templates__u_name ON templates USING btree (lower(name));


--
-- Name: landable_theme_assets__u_theme_id_asset_id; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_theme_assets__u_theme_id_asset_id ON theme_assets USING btree (theme_id, asset_id);


--
-- Name: landable_themes__u_name; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_themes__u_name ON themes USING btree (lower(name));


SET search_path = public, pg_catalog;

--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = landable, pg_catalog;

--
-- Name: landable_page_revisions__bfr_insert; Type: TRIGGER; Schema: landable; Owner: -
--

CREATE TRIGGER landable_page_revisions__bfr_insert BEFORE INSERT ON page_revisions FOR EACH ROW EXECUTE PROCEDURE pages_revision_ordinal();


--
-- Name: landable_page_revisions__no_delete; Type: TRIGGER; Schema: landable; Owner: -
--

CREATE TRIGGER landable_page_revisions__no_delete BEFORE DELETE ON page_revisions FOR EACH STATEMENT EXECUTE PROCEDURE tg_disallow();


--
-- Name: landable_page_revisions__no_update; Type: TRIGGER; Schema: landable; Owner: -
--

CREATE TRIGGER landable_page_revisions__no_update BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal ON page_revisions FOR EACH STATEMENT EXECUTE PROCEDURE tg_disallow();


--
-- Name: asset_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_assets
    ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES assets(asset_id);


--
-- Name: asset_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_revision_assets
    ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES assets(asset_id);


--
-- Name: asset_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY theme_assets
    ADD CONSTRAINT asset_id_fk FOREIGN KEY (asset_id) REFERENCES assets(asset_id);


--
-- Name: author_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY access_tokens
    ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES authors(author_id);


--
-- Name: author_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY assets
    ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES authors(author_id);


--
-- Name: author_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_revisions
    ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES authors(author_id);


--
-- Name: category_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT category_id_fk FOREIGN KEY (category_id) REFERENCES categories(category_id);


--
-- Name: page_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_assets
    ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES pages(page_id);


--
-- Name: page_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_revisions
    ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES pages(page_id);


--
-- Name: page_revision_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_revision_assets
    ADD CONSTRAINT page_revision_id_fk FOREIGN KEY (page_revision_id) REFERENCES page_revisions(page_revision_id);


--
-- Name: revision_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT revision_id_fk FOREIGN KEY (published_revision_id) REFERENCES page_revisions(page_revision_id);


--
-- Name: status_code_category_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY status_codes
    ADD CONSTRAINT status_code_category_fk FOREIGN KEY (status_code_category_id) REFERENCES status_code_categories(status_code_category_id);


--
-- Name: status_code_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT status_code_fk FOREIGN KEY (status_code_id) REFERENCES status_codes(status_code_id);


--
-- Name: theme_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY theme_assets
    ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES themes(theme_id);


--
-- Name: theme_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES themes(theme_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130510221424');
