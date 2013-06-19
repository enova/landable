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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: pages_revision_ordinal(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pages_revision_ordinal() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        BEGIN

        NEW.ordinal = (SELECT COALESCE(MAX(ordinal)+1,1)
                        FROM landable.page_revisions
                        WHERE page_id = NEW.page_id);

        RETURN NEW;

        END
       $$;


--
-- Name: tg_disallow(); Type: FUNCTION; Schema: public; Owner: -
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


SET search_path = landable, pg_catalog;

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
-- Name: categories; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE categories (
    category_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text,
    description text
);


--
-- Name: page_revisions; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE page_revisions (
    page_revision_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    ordinal integer,
    notes text,
    is_minor boolean DEFAULT false,
    page_id uuid NOT NULL,
    author_id uuid NOT NULL,
    theme_id uuid,
    snapshot_attributes text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: pages; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    page_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    published_revision_id uuid,
    is_publishable boolean DEFAULT true NOT NULL,
    theme_id uuid,
    category_id uuid,
    path text NOT NULL,
    title text,
    body text,
    status_code integer DEFAULT 200 NOT NULL,
    redirect_url text,
    meta_tags public.hstore,
    imported_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    CONSTRAINT only_valid_paths CHECK ((path ~ '^/[a-zA-Z0-9/_.~-]*$'::text)),
    CONSTRAINT only_valid_status_codes CHECK ((status_code = ANY (ARRAY[200, 301, 302, 404])))
);


--
-- Name: themes; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE themes (
    theme_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name text NOT NULL,
    body text NOT NULL,
    description text NOT NULL,
    screenshot_url text,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


SET search_path = public, pg_catalog;

--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: test; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE test (
    test_id integer NOT NULL,
    tester_id integer NOT NULL
);


SET search_path = landable, pg_catalog;

--
-- Name: access_tokens_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (access_token_id);


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
-- Name: themes_pkey; Type: CONSTRAINT; Schema: landable; Owner: -; Tablespace: 
--

ALTER TABLE ONLY themes
    ADD CONSTRAINT themes_pkey PRIMARY KEY (theme_id);


--
-- Name: category_name_lower; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX category_name_lower ON categories USING btree (lower(name));


--
-- Name: email_lower; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX email_lower ON authors USING btree (lower(email));


--
-- Name: index_landable.access_tokens_on_author_id; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE INDEX "index_landable.access_tokens_on_author_id" ON access_tokens USING btree (author_id);


--
-- Name: index_landable.authors_on_username; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_landable.authors_on_username" ON authors USING btree (username);


--
-- Name: pages_path_lower; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX pages_path_lower ON pages USING btree (lower(path));


--
-- Name: theme_name_lower; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX theme_name_lower ON themes USING btree (lower(name));


SET search_path = public, pg_catalog;

--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = landable, pg_catalog;

--
-- Name: page_revivions_bfr_insert; Type: TRIGGER; Schema: landable; Owner: -
--

CREATE TRIGGER page_revivions_bfr_insert BEFORE INSERT ON page_revisions FOR EACH ROW EXECUTE PROCEDURE public.pages_revision_ordinal();


--
-- Name: page_revivions_no_delete; Type: TRIGGER; Schema: landable; Owner: -
--

CREATE TRIGGER page_revivions_no_delete BEFORE DELETE ON page_revisions FOR EACH STATEMENT EXECUTE PROCEDURE public.tg_disallow();


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

ALTER TABLE ONLY page_revisions
    ADD CONSTRAINT page_id_fk FOREIGN KEY (page_id) REFERENCES pages(page_id);


--
-- Name: revision_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT revision_id_fk FOREIGN KEY (published_revision_id) REFERENCES page_revisions(page_revision_id);


--
-- Name: theme_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_revisions
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

INSERT INTO schema_migrations (version) VALUES ('20130619160232');
