--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: history; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA history;


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
-- Name: create_history_record(name, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_history_record(p_table_name name, p_column_values hstore) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE 
    v_column        text = '';
    v_value         text = '';
    v_column_list   text = '';
    v_values_list   text = '';
    v_sql           text = '';

BEGIN
    --Make sure arguments are not null
    IF p_table_name IS NULL THEN
        RAISE EXCEPTION 'p_table_name cannot be null!';
    ELSEIF p_column_values IS NULL THEN
        RAISE EXCEPTION 'p_column_values cannot be null!';
    END IF;

    --Setup initial statement
    v_sql := 'INSERT INTO ' || p_table_name || ' (';

    --Loop through columns & values, concatenate on to existing lists
    FOR v_column, v_value IN SELECT (each(p_column_values)).key, (each(p_column_values)).value
    LOOP
        v_column_list := v_column_list || ', ' || v_column;
        v_values_list := v_values_list || ', ' || v_value;
    END LOOP;

    --Add ending paren
    v_column_list := v_column_list || ')';
    v_values_list := v_values_list || ')';

    --Create entire insert statement
    v_sql := v_sql || v_column_list || ' VALUES (' || v_values_list;

    --Remove bogus commas
    v_sql := replace(v_sql, '(,', '(');

    IF v_sql LIKE '%;%' THEN
        RAISE EXCEPTION 'Invalid character in statement, %', v_sql;
    END IF;

    EXECUTE v_sql;

    RETURN v_sql;
END;
$$;


--
-- Name: create_history_table(text, hstore); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_history_table(p_table_name text, p_table_columns hstore) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sql text = 'CREATE TABLE ' || p_table_name || '(';
    v_out text = p_table_name || '_ID INTEGER NOT NULL';
    v_key text = '';
    v_value text = '';
BEGIN
    --Check for null args
    IF p_table_name IS NULL THEN
        RAISE EXCEPTION 'p_table_name cannot be null!';
    ELSEIF p_table_columns IS NULL THEN
        RAISE EXCEPTION 'p_table_columns cannot be null!';
    END IF;

    --Loop through columns/types, creating sql statement
    FOR v_key, v_value IN SELECT (each(p_table_columns)).key, (each(p_table_columns)).value
    LOOP
        v_out := v_out || ', ' || v_key || ' ' || v_value;
    END LOOP;

    --Put together final statement
    v_sql := v_sql || v_out || ');';

    EXECUTE v_sql;

    RETURN v_sql;
END;
$$;


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


SET search_path = history, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: table_columns; Type: TABLE; Schema: history; Owner: -; Tablespace: 
--

CREATE TABLE table_columns (
    table_column_id integer NOT NULL,
    table_name text NOT NULL,
    column_name text NOT NULL,
    column_data_type text NOT NULL,
    column_is_nullable boolean NOT NULL,
    column_is_changeable boolean NOT NULL
);


SET search_path = landable, pg_catalog;

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
-- Name: page_revisions; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE page_revisions (
    page_revision_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    ordinal integer,
    page_id uuid NOT NULL,
    author_id uuid NOT NULL,
    snapshot_attributes public.hstore NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: pages; Type: TABLE; Schema: landable; Owner: -; Tablespace: 
--

CREATE TABLE pages (
    page_id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    published_revision_id uuid,
    path text NOT NULL,
    theme_name text,
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


SET search_path = history, pg_catalog;

--
-- Name: table_columns_pkey; Type: CONSTRAINT; Schema: history; Owner: -; Tablespace: 
--

ALTER TABLE ONLY table_columns
    ADD CONSTRAINT table_columns_pkey PRIMARY KEY (table_column_id);


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
-- Name: index_landable.authors_on_email; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_landable.authors_on_email" ON authors USING btree (email);


--
-- Name: index_landable.authors_on_username; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_landable.authors_on_username" ON authors USING btree (username);


--
-- Name: index_landable.pages_on_path; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX "index_landable.pages_on_path" ON pages USING btree (path);


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
-- Name: author_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_revisions
    ADD CONSTRAINT author_id_fk FOREIGN KEY (author_id) REFERENCES authors(author_id);


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
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20130610150814');
