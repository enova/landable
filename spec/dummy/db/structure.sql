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
-- Name: traffic; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA traffic;


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
    file_size integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


--
-- Name: TABLE assets; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE assets IS 'List of all assets uploaded.
              Examples of assets include images (jpg, png, gif) and documents (PDF).
              data, md5sum, mime_type, file_size are populated via the rails gem CarrierWave when a record is created.';


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
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    theme_id uuid,
    category_id uuid,
    redirect_url text,
    body text,
    title text,
    path text,
    meta_tags public.hstore,
    head_content text,
    status_code smallint
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
    path text NOT NULL,
    title text,
    body text,
    redirect_url text,
    meta_tags public.hstore,
    imported_at timestamp without time zone,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    updated_by_author_id uuid,
    lock_version integer DEFAULT 0 NOT NULL,
    head_content text,
    status_code smallint DEFAULT 200 NOT NULL,
    CONSTRAINT only_valid_paths CHECK ((path ~ '^/[a-zA-Z0-9/_.~-]*$'::text))
);


--
-- Name: TABLE pages; Type: COMMENT; Schema: landable; Owner: -
--

COMMENT ON TABLE pages IS 'Pages serve as a draft, where you can make changes, preview and save those changes without having to update the live page on the website.
              Pages also point to their published version, where applicable.';


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
    updated_at timestamp without time zone,
    file text,
    extension text,
    editable boolean DEFAULT true NOT NULL
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


SET search_path = traffic, pg_catalog;

--
-- Name: accesses; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE accesses (
    access_id integer NOT NULL,
    path_id integer NOT NULL,
    visitor_id integer NOT NULL,
    last_accessed_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: accesses_access_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE accesses_access_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accesses_access_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE accesses_access_id_seq OWNED BY accesses.access_id;


--
-- Name: browsers; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE browsers (
    browser_id smallint NOT NULL,
    browser text NOT NULL
);


--
-- Name: devices; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE devices (
    device_id integer NOT NULL,
    device text NOT NULL
);


--
-- Name: ip_addresses; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE ip_addresses (
    ip_address_id integer NOT NULL,
    ip_address inet NOT NULL
);


--
-- Name: paths; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE paths (
    path_id integer NOT NULL,
    path text NOT NULL
);


--
-- Name: platforms; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE platforms (
    platform_id smallint NOT NULL,
    platform text NOT NULL
);


--
-- Name: user_agent_types; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE user_agent_types (
    user_agent_type_id smallint NOT NULL,
    user_agent_type text NOT NULL
);


--
-- Name: user_agents; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE user_agents (
    user_agent_id integer NOT NULL,
    user_agent_type_id smallint,
    device_id integer,
    platform_id smallint,
    browser_id smallint,
    browser_version text,
    user_agent text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: visitors; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE visitors (
    visitor_id integer NOT NULL,
    ip_address_id integer NOT NULL,
    user_agent_id integer NOT NULL
);


--
-- Name: visitors_v; Type: VIEW; Schema: traffic; Owner: -
--

CREATE VIEW visitors_v AS
    SELECT v.visitor_id, ip_addresses.ip_address, ua.user_agent, uat.user_agent_type, d.device, p.platform, b.browser, ua.browser_version FROM ((((((visitors v JOIN ip_addresses USING (ip_address_id)) JOIN user_agents ua USING (user_agent_id)) LEFT JOIN user_agent_types uat USING (user_agent_type_id)) LEFT JOIN devices d USING (device_id)) LEFT JOIN platforms p USING (platform_id)) LEFT JOIN browsers b USING (browser_id));


--
-- Name: accesses_v; Type: VIEW; Schema: traffic; Owner: -
--

CREATE VIEW accesses_v AS
    SELECT a.access_id, p.path, a.visitor_id, v.ip_address, v.user_agent_type, v.device, v.platform, v.browser, v.browser_version, v.user_agent FROM ((accesses a JOIN paths p USING (path_id)) JOIN visitors_v v USING (visitor_id));


--
-- Name: ad_groups; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE ad_groups (
    ad_group_id integer NOT NULL,
    ad_group text NOT NULL
);


--
-- Name: ad_groups_ad_group_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE ad_groups_ad_group_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ad_groups_ad_group_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE ad_groups_ad_group_id_seq OWNED BY ad_groups.ad_group_id;


--
-- Name: ad_types; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE ad_types (
    ad_type_id smallint NOT NULL,
    ad_type text NOT NULL
);


--
-- Name: ad_types_ad_type_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE ad_types_ad_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ad_types_ad_type_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE ad_types_ad_type_id_seq OWNED BY ad_types.ad_type_id;


--
-- Name: attributions; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE attributions (
    attribution_id integer NOT NULL,
    ad_type_id smallint,
    ad_group_id integer,
    bid_match_type_id smallint,
    campaign_id integer,
    content_id integer,
    creative_id integer,
    device_type_id smallint,
    experiment_id integer,
    keyword_id integer,
    match_type_id smallint,
    medium_id integer,
    network_id integer,
    placement_id integer,
    position_id smallint,
    search_term_id integer,
    source_id integer,
    target_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: attributions_attribution_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE attributions_attribution_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: attributions_attribution_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE attributions_attribution_id_seq OWNED BY attributions.attribution_id;


--
-- Name: bid_match_types; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE bid_match_types (
    bid_match_type_id smallint NOT NULL,
    bid_match_type text NOT NULL
);


--
-- Name: campaigns; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE campaigns (
    campaign_id integer NOT NULL,
    campaign text NOT NULL
);


--
-- Name: contents; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE contents (
    content_id integer NOT NULL,
    content text NOT NULL
);


--
-- Name: creatives; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE creatives (
    creative_id integer NOT NULL,
    creative text NOT NULL
);


--
-- Name: device_types; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE device_types (
    device_type_id smallint NOT NULL,
    device_type text NOT NULL
);


--
-- Name: experiments; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE experiments (
    experiment_id integer NOT NULL,
    experiment text NOT NULL
);


--
-- Name: keywords; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE keywords (
    keyword_id integer NOT NULL,
    keyword text NOT NULL
);


--
-- Name: match_types; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE match_types (
    match_type_id smallint NOT NULL,
    match_type text NOT NULL
);


--
-- Name: mediums; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE mediums (
    medium_id integer NOT NULL,
    medium text NOT NULL
);


--
-- Name: networks; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE networks (
    network_id integer NOT NULL,
    network text NOT NULL
);


--
-- Name: placements; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE placements (
    placement_id integer NOT NULL,
    placement text NOT NULL
);


--
-- Name: positions; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE positions (
    position_id smallint NOT NULL,
    "position" text NOT NULL
);


--
-- Name: search_terms; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE search_terms (
    search_term_id integer NOT NULL,
    search_term text NOT NULL
);


--
-- Name: sources; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE sources (
    source_id integer NOT NULL,
    source text NOT NULL
);


--
-- Name: targets; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE targets (
    target_id integer NOT NULL,
    target text NOT NULL
);


--
-- Name: attributions_v; Type: VIEW; Schema: traffic; Owner: -
--

CREATE VIEW attributions_v AS
    SELECT a.attribution_id, at.ad_type, ag.ad_group, bmt.bid_match_type, c.campaign, cs.content, ct.creative, dt.device_type, e.experiment, k.keyword, mt.match_type, m.medium, n.network, p.placement, ps."position", st.search_term, s.source, t.target, a.created_at FROM (((((((((((((((((attributions a LEFT JOIN ad_types at USING (ad_type_id)) LEFT JOIN ad_groups ag USING (ad_group_id)) LEFT JOIN bid_match_types bmt USING (bid_match_type_id)) LEFT JOIN campaigns c USING (campaign_id)) LEFT JOIN contents cs USING (content_id)) LEFT JOIN creatives ct USING (creative_id)) LEFT JOIN device_types dt USING (device_type_id)) LEFT JOIN experiments e USING (experiment_id)) LEFT JOIN keywords k USING (keyword_id)) LEFT JOIN match_types mt USING (match_type_id)) LEFT JOIN mediums m USING (medium_id)) LEFT JOIN networks n USING (network_id)) LEFT JOIN placements p USING (placement_id)) LEFT JOIN positions ps USING (position_id)) LEFT JOIN search_terms st USING (search_term_id)) LEFT JOIN sources s USING (source_id)) LEFT JOIN targets t USING (target_id));


--
-- Name: bid_match_types_bid_match_type_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE bid_match_types_bid_match_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bid_match_types_bid_match_type_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE bid_match_types_bid_match_type_id_seq OWNED BY bid_match_types.bid_match_type_id;


--
-- Name: browsers_browser_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE browsers_browser_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: browsers_browser_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE browsers_browser_id_seq OWNED BY browsers.browser_id;


--
-- Name: campaigns_campaign_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE campaigns_campaign_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campaigns_campaign_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE campaigns_campaign_id_seq OWNED BY campaigns.campaign_id;


--
-- Name: cities; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE cities (
    city_id integer NOT NULL,
    city text NOT NULL
);


--
-- Name: cities_city_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE cities_city_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cities_city_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE cities_city_id_seq OWNED BY cities.city_id;


--
-- Name: contents_content_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE contents_content_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contents_content_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE contents_content_id_seq OWNED BY contents.content_id;


--
-- Name: cookies; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE cookies (
    cookie_id uuid DEFAULT public.uuid_generate_v4() NOT NULL
);


--
-- Name: countries; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE countries (
    country_id integer NOT NULL,
    country text NOT NULL
);


--
-- Name: countries_country_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE countries_country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: countries_country_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE countries_country_id_seq OWNED BY countries.country_id;


--
-- Name: creatives_creative_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE creatives_creative_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: creatives_creative_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE creatives_creative_id_seq OWNED BY creatives.creative_id;


--
-- Name: device_types_device_type_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE device_types_device_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: device_types_device_type_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE device_types_device_type_id_seq OWNED BY device_types.device_type_id;


--
-- Name: devices_device_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE devices_device_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: devices_device_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE devices_device_id_seq OWNED BY devices.device_id;


--
-- Name: domains; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE domains (
    domain_id integer NOT NULL,
    domain text NOT NULL
);


--
-- Name: domains_domain_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE domains_domain_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: domains_domain_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE domains_domain_id_seq OWNED BY domains.domain_id;


--
-- Name: event_types; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE event_types (
    event_type_id integer NOT NULL,
    event_type text NOT NULL
);


--
-- Name: event_types_event_type_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE event_types_event_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_types_event_type_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE event_types_event_type_id_seq OWNED BY event_types.event_type_id;


--
-- Name: events; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE events (
    event_id integer NOT NULL,
    event_type_id integer NOT NULL,
    visit_id integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    meta public.hstore
);


--
-- Name: events_event_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE events_event_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: events_event_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE events_event_id_seq OWNED BY events.event_id;


--
-- Name: experiments_experiment_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE experiments_experiment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: experiments_experiment_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE experiments_experiment_id_seq OWNED BY experiments.experiment_id;


--
-- Name: http_methods; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE http_methods (
    http_method_id smallint NOT NULL,
    http_method text NOT NULL
);


--
-- Name: http_methods_http_method_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE http_methods_http_method_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: http_methods_http_method_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE http_methods_http_method_id_seq OWNED BY http_methods.http_method_id;


--
-- Name: ip_addresses_ip_address_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE ip_addresses_ip_address_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_addresses_ip_address_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE ip_addresses_ip_address_id_seq OWNED BY ip_addresses.ip_address_id;


--
-- Name: ip_lookups; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE ip_lookups (
    ip_lookup_id integer NOT NULL,
    ip_address_id integer NOT NULL,
    domain_id integer,
    location_id integer,
    latitude real,
    longitude real,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: ip_lookups_ip_lookup_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE ip_lookups_ip_lookup_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_lookups_ip_lookup_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE ip_lookups_ip_lookup_id_seq OWNED BY ip_lookups.ip_lookup_id;


--
-- Name: keywords_keyword_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE keywords_keyword_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: keywords_keyword_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE keywords_keyword_id_seq OWNED BY keywords.keyword_id;


--
-- Name: locations; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE locations (
    location_id integer NOT NULL,
    country_id integer,
    region_id integer,
    city_id integer
);


--
-- Name: locations_location_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE locations_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: locations_location_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE locations_location_id_seq OWNED BY locations.location_id;


--
-- Name: match_types_match_type_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE match_types_match_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: match_types_match_type_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE match_types_match_type_id_seq OWNED BY match_types.match_type_id;


--
-- Name: mediums_medium_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE mediums_medium_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mediums_medium_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE mediums_medium_id_seq OWNED BY mediums.medium_id;


--
-- Name: mime_types; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE mime_types (
    mime_type_id smallint NOT NULL,
    mime_type text NOT NULL
);


--
-- Name: mime_types_mime_type_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE mime_types_mime_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mime_types_mime_type_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE mime_types_mime_type_id_seq OWNED BY mime_types.mime_type_id;


--
-- Name: networks_network_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE networks_network_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: networks_network_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE networks_network_id_seq OWNED BY networks.network_id;


--
-- Name: owners; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE owners (
    owner_id integer NOT NULL,
    owner integer NOT NULL
);


--
-- Name: owners_owner_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE owners_owner_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: owners_owner_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE owners_owner_id_seq OWNED BY owners.owner_id;


--
-- Name: ownerships; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE ownerships (
    owner_id integer NOT NULL,
    cookie_id uuid NOT NULL
);


--
-- Name: page_views; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE page_views (
    page_view_id integer NOT NULL,
    visit_id integer NOT NULL,
    path_id integer NOT NULL,
    query_string_id integer NOT NULL,
    mime_type_id smallint NOT NULL,
    http_method_id smallint NOT NULL,
    page_revision_id uuid,
    request_id uuid,
    click_id text,
    content_length integer,
    http_status integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: page_views_page_view_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE page_views_page_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: page_views_page_view_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE page_views_page_view_id_seq OWNED BY page_views.page_view_id;


--
-- Name: query_strings; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE query_strings (
    query_string_id integer NOT NULL,
    query_string text NOT NULL
);


--
-- Name: page_views_v; Type: VIEW; Schema: traffic; Owner: -
--

CREATE VIEW page_views_v AS
    SELECT pv.page_view_id, pv.visit_id, p.path, qs.query_string, mt.mime_type, http_methods.http_method, pr.ordinal AS page_revision, pv.content_length, pv.http_status, pv.request_id, pv.click_id, pv.created_at FROM (((((page_views pv JOIN paths p USING (path_id)) LEFT JOIN query_strings qs USING (query_string_id)) LEFT JOIN mime_types mt USING (mime_type_id)) LEFT JOIN http_methods USING (http_method_id)) LEFT JOIN landable.page_revisions pr USING (page_revision_id));


--
-- Name: paths_path_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE paths_path_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: paths_path_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE paths_path_id_seq OWNED BY paths.path_id;


--
-- Name: placements_placement_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE placements_placement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: placements_placement_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE placements_placement_id_seq OWNED BY placements.placement_id;


--
-- Name: platforms_platform_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE platforms_platform_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: platforms_platform_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE platforms_platform_id_seq OWNED BY platforms.platform_id;


--
-- Name: positions_position_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE positions_position_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: positions_position_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE positions_position_id_seq OWNED BY positions.position_id;


--
-- Name: query_strings_query_string_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE query_strings_query_string_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: query_strings_query_string_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE query_strings_query_string_id_seq OWNED BY query_strings.query_string_id;


--
-- Name: referers; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE referers (
    referer_id integer NOT NULL,
    domain_id integer NOT NULL,
    path_id integer NOT NULL,
    query_string_id integer NOT NULL,
    attribution_id integer NOT NULL
);


--
-- Name: referers_referer_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE referers_referer_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: referers_referer_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE referers_referer_id_seq OWNED BY referers.referer_id;


--
-- Name: regions; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE regions (
    region_id integer NOT NULL,
    region text NOT NULL
);


--
-- Name: regions_region_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE regions_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regions_region_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE regions_region_id_seq OWNED BY regions.region_id;


--
-- Name: search_terms_search_term_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE search_terms_search_term_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: search_terms_search_term_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE search_terms_search_term_id_seq OWNED BY search_terms.search_term_id;


--
-- Name: sources_source_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE sources_source_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sources_source_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE sources_source_id_seq OWNED BY sources.source_id;


--
-- Name: targets_target_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE targets_target_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: targets_target_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE targets_target_id_seq OWNED BY targets.target_id;


--
-- Name: visits; Type: TABLE; Schema: traffic; Owner: -; Tablespace: 
--

CREATE TABLE visits (
    visit_id integer NOT NULL,
    cookie_id uuid NOT NULL,
    visitor_id integer NOT NULL,
    attribution_id integer NOT NULL,
    referer_id integer,
    owner_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    do_not_track boolean
);


--
-- Name: visits_v; Type: VIEW; Schema: traffic; Owner: -
--

CREATE VIEW visits_v AS
    SELECT v.visit_id, v.attribution_id, v.cookie_id AS cookie, vs.ip_address, vs.user_agent, vs.user_agent_type, vs.device, vs.platform, vs.browser, vs.browser_version, o.owner AS customer_id, v.do_not_track, v.created_at, et.event_type FROM ((((visits v JOIN visitors_v vs USING (visitor_id)) LEFT JOIN owners o USING (owner_id)) LEFT JOIN events e USING (visit_id)) LEFT JOIN event_types et USING (event_type_id));


--
-- Name: tracking; Type: VIEW; Schema: traffic; Owner: -
--

CREATE VIEW tracking AS
    SELECT v.customer_id, v.visit_id AS visit, v.cookie, v.ip_address, v.user_agent, v.user_agent_type, v.device, v.platform, v.browser, v.browser_version, v.do_not_track, v.created_at AS visit_created_at, pv.path, pv.query_string, pv.mime_type, pv.http_method, pv.page_revision, pv.content_length, pv.http_status, pv.request_id, pv.click_id, pv.created_at AS page_view_created_at, av.ad_type, av.ad_group, av.bid_match_type, av.campaign, av.content, av.creative, av.device_type, av.experiment, av.keyword, av.match_type, av.medium, av.network, av.placement, av."position", av.search_term, av.source, av.target, av.created_at AS attribution_created_at FROM ((visits_v v JOIN page_views_v pv USING (visit_id)) JOIN attributions_v av USING (attribution_id)) WHERE (((pv.path !~~ '%stylesheets%'::text) AND (pv.path !~~ '%javascript%'::text)) AND (pv.path !~~ '%images%'::text));


--
-- Name: user_agent_types_user_agent_type_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE user_agent_types_user_agent_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_agent_types_user_agent_type_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE user_agent_types_user_agent_type_id_seq OWNED BY user_agent_types.user_agent_type_id;


--
-- Name: user_agents_user_agent_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE user_agents_user_agent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_agents_user_agent_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE user_agents_user_agent_id_seq OWNED BY user_agents.user_agent_id;


--
-- Name: visitors_visitor_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE visitors_visitor_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visitors_visitor_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE visitors_visitor_id_seq OWNED BY visitors.visitor_id;


--
-- Name: visits_visit_id_seq; Type: SEQUENCE; Schema: traffic; Owner: -
--

CREATE SEQUENCE visits_visit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: visits_visit_id_seq; Type: SEQUENCE OWNED BY; Schema: traffic; Owner: -
--

ALTER SEQUENCE visits_visit_id_seq OWNED BY visits.visit_id;


--
-- Name: access_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY accesses ALTER COLUMN access_id SET DEFAULT nextval('accesses_access_id_seq'::regclass);


--
-- Name: ad_group_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ad_groups ALTER COLUMN ad_group_id SET DEFAULT nextval('ad_groups_ad_group_id_seq'::regclass);


--
-- Name: ad_type_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ad_types ALTER COLUMN ad_type_id SET DEFAULT nextval('ad_types_ad_type_id_seq'::regclass);


--
-- Name: attribution_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions ALTER COLUMN attribution_id SET DEFAULT nextval('attributions_attribution_id_seq'::regclass);


--
-- Name: bid_match_type_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY bid_match_types ALTER COLUMN bid_match_type_id SET DEFAULT nextval('bid_match_types_bid_match_type_id_seq'::regclass);


--
-- Name: browser_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY browsers ALTER COLUMN browser_id SET DEFAULT nextval('browsers_browser_id_seq'::regclass);


--
-- Name: campaign_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY campaigns ALTER COLUMN campaign_id SET DEFAULT nextval('campaigns_campaign_id_seq'::regclass);


--
-- Name: city_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY cities ALTER COLUMN city_id SET DEFAULT nextval('cities_city_id_seq'::regclass);


--
-- Name: content_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY contents ALTER COLUMN content_id SET DEFAULT nextval('contents_content_id_seq'::regclass);


--
-- Name: country_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY countries ALTER COLUMN country_id SET DEFAULT nextval('countries_country_id_seq'::regclass);


--
-- Name: creative_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY creatives ALTER COLUMN creative_id SET DEFAULT nextval('creatives_creative_id_seq'::regclass);


--
-- Name: device_type_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY device_types ALTER COLUMN device_type_id SET DEFAULT nextval('device_types_device_type_id_seq'::regclass);


--
-- Name: device_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY devices ALTER COLUMN device_id SET DEFAULT nextval('devices_device_id_seq'::regclass);


--
-- Name: domain_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY domains ALTER COLUMN domain_id SET DEFAULT nextval('domains_domain_id_seq'::regclass);


--
-- Name: event_type_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY event_types ALTER COLUMN event_type_id SET DEFAULT nextval('event_types_event_type_id_seq'::regclass);


--
-- Name: event_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY events ALTER COLUMN event_id SET DEFAULT nextval('events_event_id_seq'::regclass);


--
-- Name: experiment_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY experiments ALTER COLUMN experiment_id SET DEFAULT nextval('experiments_experiment_id_seq'::regclass);


--
-- Name: http_method_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY http_methods ALTER COLUMN http_method_id SET DEFAULT nextval('http_methods_http_method_id_seq'::regclass);


--
-- Name: ip_address_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ip_addresses ALTER COLUMN ip_address_id SET DEFAULT nextval('ip_addresses_ip_address_id_seq'::regclass);


--
-- Name: ip_lookup_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ip_lookups ALTER COLUMN ip_lookup_id SET DEFAULT nextval('ip_lookups_ip_lookup_id_seq'::regclass);


--
-- Name: keyword_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY keywords ALTER COLUMN keyword_id SET DEFAULT nextval('keywords_keyword_id_seq'::regclass);


--
-- Name: location_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY locations ALTER COLUMN location_id SET DEFAULT nextval('locations_location_id_seq'::regclass);


--
-- Name: match_type_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY match_types ALTER COLUMN match_type_id SET DEFAULT nextval('match_types_match_type_id_seq'::regclass);


--
-- Name: medium_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY mediums ALTER COLUMN medium_id SET DEFAULT nextval('mediums_medium_id_seq'::regclass);


--
-- Name: mime_type_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY mime_types ALTER COLUMN mime_type_id SET DEFAULT nextval('mime_types_mime_type_id_seq'::regclass);


--
-- Name: network_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY networks ALTER COLUMN network_id SET DEFAULT nextval('networks_network_id_seq'::regclass);


--
-- Name: owner_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY owners ALTER COLUMN owner_id SET DEFAULT nextval('owners_owner_id_seq'::regclass);


--
-- Name: page_view_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY page_views ALTER COLUMN page_view_id SET DEFAULT nextval('page_views_page_view_id_seq'::regclass);


--
-- Name: path_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY paths ALTER COLUMN path_id SET DEFAULT nextval('paths_path_id_seq'::regclass);


--
-- Name: placement_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY placements ALTER COLUMN placement_id SET DEFAULT nextval('placements_placement_id_seq'::regclass);


--
-- Name: platform_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY platforms ALTER COLUMN platform_id SET DEFAULT nextval('platforms_platform_id_seq'::regclass);


--
-- Name: position_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY positions ALTER COLUMN position_id SET DEFAULT nextval('positions_position_id_seq'::regclass);


--
-- Name: query_string_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY query_strings ALTER COLUMN query_string_id SET DEFAULT nextval('query_strings_query_string_id_seq'::regclass);


--
-- Name: referer_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY referers ALTER COLUMN referer_id SET DEFAULT nextval('referers_referer_id_seq'::regclass);


--
-- Name: region_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY regions ALTER COLUMN region_id SET DEFAULT nextval('regions_region_id_seq'::regclass);


--
-- Name: search_term_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY search_terms ALTER COLUMN search_term_id SET DEFAULT nextval('search_terms_search_term_id_seq'::regclass);


--
-- Name: source_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY sources ALTER COLUMN source_id SET DEFAULT nextval('sources_source_id_seq'::regclass);


--
-- Name: target_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY targets ALTER COLUMN target_id SET DEFAULT nextval('targets_target_id_seq'::regclass);


--
-- Name: user_agent_type_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY user_agent_types ALTER COLUMN user_agent_type_id SET DEFAULT nextval('user_agent_types_user_agent_type_id_seq'::regclass);


--
-- Name: user_agent_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY user_agents ALTER COLUMN user_agent_id SET DEFAULT nextval('user_agents_user_agent_id_seq'::regclass);


--
-- Name: visitor_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visitors ALTER COLUMN visitor_id SET DEFAULT nextval('visitors_visitor_id_seq'::regclass);


--
-- Name: visit_id; Type: DEFAULT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visits ALTER COLUMN visit_id SET DEFAULT nextval('visits_visit_id_seq'::regclass);


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


SET search_path = traffic, pg_catalog;

--
-- Name: accesses_path_id_visitor_id_key; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accesses
    ADD CONSTRAINT accesses_path_id_visitor_id_key UNIQUE (path_id, visitor_id);


--
-- Name: accesses_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY accesses
    ADD CONSTRAINT accesses_pkey PRIMARY KEY (access_id);


--
-- Name: ad_groups_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ad_groups
    ADD CONSTRAINT ad_groups_pkey PRIMARY KEY (ad_group_id);


--
-- Name: ad_types_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ad_types
    ADD CONSTRAINT ad_types_pkey PRIMARY KEY (ad_type_id);


--
-- Name: attributions_ad_type_id_ad_group_id_bid_match_type_id_campa_key; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_ad_type_id_ad_group_id_bid_match_type_id_campa_key UNIQUE (ad_type_id, ad_group_id, bid_match_type_id, campaign_id, content_id, creative_id, device_type_id, experiment_id, keyword_id, match_type_id, medium_id, network_id, placement_id, position_id, search_term_id, source_id, target_id);


--
-- Name: attributions_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_pkey PRIMARY KEY (attribution_id);


--
-- Name: bid_match_types_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bid_match_types
    ADD CONSTRAINT bid_match_types_pkey PRIMARY KEY (bid_match_type_id);


--
-- Name: browsers_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY browsers
    ADD CONSTRAINT browsers_pkey PRIMARY KEY (browser_id);


--
-- Name: campaigns_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY campaigns
    ADD CONSTRAINT campaigns_pkey PRIMARY KEY (campaign_id);


--
-- Name: cities_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cities
    ADD CONSTRAINT cities_pkey PRIMARY KEY (city_id);


--
-- Name: contents_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY contents
    ADD CONSTRAINT contents_pkey PRIMARY KEY (content_id);


--
-- Name: cookies_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY cookies
    ADD CONSTRAINT cookies_pkey PRIMARY KEY (cookie_id);


--
-- Name: countries_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY countries
    ADD CONSTRAINT countries_pkey PRIMARY KEY (country_id);


--
-- Name: creatives_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY creatives
    ADD CONSTRAINT creatives_pkey PRIMARY KEY (creative_id);


--
-- Name: device_types_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY device_types
    ADD CONSTRAINT device_types_pkey PRIMARY KEY (device_type_id);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (device_id);


--
-- Name: domains_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY domains
    ADD CONSTRAINT domains_pkey PRIMARY KEY (domain_id);


--
-- Name: event_types_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event_types
    ADD CONSTRAINT event_types_pkey PRIMARY KEY (event_type_id);


--
-- Name: events_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_pkey PRIMARY KEY (event_id);


--
-- Name: experiments_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY experiments
    ADD CONSTRAINT experiments_pkey PRIMARY KEY (experiment_id);


--
-- Name: http_methods_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY http_methods
    ADD CONSTRAINT http_methods_pkey PRIMARY KEY (http_method_id);


--
-- Name: ip_addresses_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ip_addresses
    ADD CONSTRAINT ip_addresses_pkey PRIMARY KEY (ip_address_id);


--
-- Name: ip_lookups_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ip_lookups
    ADD CONSTRAINT ip_lookups_pkey PRIMARY KEY (ip_lookup_id);


--
-- Name: keywords_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY keywords
    ADD CONSTRAINT keywords_pkey PRIMARY KEY (keyword_id);


--
-- Name: locations_country_id_region_id_city_id_key; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_country_id_region_id_city_id_key UNIQUE (country_id, region_id, city_id);


--
-- Name: locations_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (location_id);


--
-- Name: match_types_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY match_types
    ADD CONSTRAINT match_types_pkey PRIMARY KEY (match_type_id);


--
-- Name: mediums_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mediums
    ADD CONSTRAINT mediums_pkey PRIMARY KEY (medium_id);


--
-- Name: mime_types_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mime_types
    ADD CONSTRAINT mime_types_pkey PRIMARY KEY (mime_type_id);


--
-- Name: networks_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY networks
    ADD CONSTRAINT networks_pkey PRIMARY KEY (network_id);


--
-- Name: owners_owner_key; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY owners
    ADD CONSTRAINT owners_owner_key UNIQUE (owner);


--
-- Name: owners_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY owners
    ADD CONSTRAINT owners_pkey PRIMARY KEY (owner_id);


--
-- Name: ownerships_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_pkey PRIMARY KEY (owner_id, cookie_id);


--
-- Name: page_views_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_pkey PRIMARY KEY (page_view_id);


--
-- Name: paths_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY paths
    ADD CONSTRAINT paths_pkey PRIMARY KEY (path_id);


--
-- Name: placements_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY placements
    ADD CONSTRAINT placements_pkey PRIMARY KEY (placement_id);


--
-- Name: platforms_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY platforms
    ADD CONSTRAINT platforms_pkey PRIMARY KEY (platform_id);


--
-- Name: positions_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY positions
    ADD CONSTRAINT positions_pkey PRIMARY KEY (position_id);


--
-- Name: query_strings_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY query_strings
    ADD CONSTRAINT query_strings_pkey PRIMARY KEY (query_string_id);


--
-- Name: referers_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY referers
    ADD CONSTRAINT referers_pkey PRIMARY KEY (referer_id);


--
-- Name: regions_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY regions
    ADD CONSTRAINT regions_pkey PRIMARY KEY (region_id);


--
-- Name: search_terms_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY search_terms
    ADD CONSTRAINT search_terms_pkey PRIMARY KEY (search_term_id);


--
-- Name: sources_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sources
    ADD CONSTRAINT sources_pkey PRIMARY KEY (source_id);


--
-- Name: targets_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY targets
    ADD CONSTRAINT targets_pkey PRIMARY KEY (target_id);


--
-- Name: user_agent_types_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_agent_types
    ADD CONSTRAINT user_agent_types_pkey PRIMARY KEY (user_agent_type_id);


--
-- Name: user_agents_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agents_pkey PRIMARY KEY (user_agent_id);


--
-- Name: user_agents_user_agent_key; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agents_user_agent_key UNIQUE (user_agent);


--
-- Name: visitors_ip_address_id_user_agent_id_key; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visitors
    ADD CONSTRAINT visitors_ip_address_id_user_agent_id_key UNIQUE (ip_address_id, user_agent_id);


--
-- Name: visitors_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visitors
    ADD CONSTRAINT visitors_pkey PRIMARY KEY (visitor_id);


--
-- Name: visits_pkey; Type: CONSTRAINT; Schema: traffic; Owner: -; Tablespace: 
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT visits_pkey PRIMARY KEY (visit_id);


SET search_path = landable, pg_catalog;

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
-- Name: landable_page_revisions__path_status_code; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE INDEX landable_page_revisions__path_status_code ON page_revisions USING btree (path, status_code);


--
-- Name: landable_pages__trgm_path; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE INDEX landable_pages__trgm_path ON pages USING gin (path public.gin_trgm_ops);


--
-- Name: landable_pages__u_path; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_pages__u_path ON pages USING btree (lower(path));


--
-- Name: landable_templates__u_name; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_templates__u_name ON templates USING btree (lower(name));


--
-- Name: landable_theme_assets__u_theme_id_asset_id; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_theme_assets__u_theme_id_asset_id ON theme_assets USING btree (theme_id, asset_id);


--
-- Name: landable_themes__u_file; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_themes__u_file ON themes USING btree (lower(file));


--
-- Name: landable_themes__u_name; Type: INDEX; Schema: landable; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX landable_themes__u_name ON themes USING btree (lower(name));


SET search_path = public, pg_catalog;

--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


SET search_path = traffic, pg_catalog;

--
-- Name: accesses_visitor_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX accesses_visitor_id_idx ON accesses USING btree (visitor_id);


--
-- Name: ad_groups__u_ad_group; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX ad_groups__u_ad_group ON ad_groups USING btree (ad_group);


--
-- Name: ad_types__u_ad_type; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX ad_types__u_ad_type ON ad_types USING btree (ad_type);


--
-- Name: attributions_ad_group_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_ad_group_id_idx ON attributions USING btree (ad_group_id);


--
-- Name: attributions_ad_type_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_ad_type_id_idx ON attributions USING btree (ad_type_id);


--
-- Name: attributions_bid_match_type_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_bid_match_type_id_idx ON attributions USING btree (bid_match_type_id);


--
-- Name: attributions_campaign_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_campaign_id_idx ON attributions USING btree (campaign_id);


--
-- Name: attributions_content_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_content_id_idx ON attributions USING btree (content_id);


--
-- Name: attributions_creative_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_creative_id_idx ON attributions USING btree (creative_id);


--
-- Name: attributions_device_type_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_device_type_id_idx ON attributions USING btree (device_type_id);


--
-- Name: attributions_experiment_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_experiment_id_idx ON attributions USING btree (experiment_id);


--
-- Name: attributions_keyword_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_keyword_id_idx ON attributions USING btree (keyword_id);


--
-- Name: attributions_match_type_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_match_type_id_idx ON attributions USING btree (match_type_id);


--
-- Name: attributions_medium_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_medium_id_idx ON attributions USING btree (medium_id);


--
-- Name: attributions_network_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_network_id_idx ON attributions USING btree (network_id);


--
-- Name: attributions_placement_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_placement_id_idx ON attributions USING btree (placement_id);


--
-- Name: attributions_position_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_position_id_idx ON attributions USING btree (position_id);


--
-- Name: attributions_search_term_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_search_term_id_idx ON attributions USING btree (search_term_id);


--
-- Name: attributions_source_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_source_id_idx ON attributions USING btree (source_id);


--
-- Name: attributions_target_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX attributions_target_id_idx ON attributions USING btree (target_id);


--
-- Name: bid_match_types__u_bid_match_type; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX bid_match_types__u_bid_match_type ON bid_match_types USING btree (bid_match_type);


--
-- Name: browsers__u_browser; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX browsers__u_browser ON browsers USING btree (browser);


--
-- Name: campaigns__u_campaign; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX campaigns__u_campaign ON campaigns USING btree (campaign);


--
-- Name: cities__u_city; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX cities__u_city ON cities USING btree (city);


--
-- Name: contents__u_content; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX contents__u_content ON contents USING btree (content);


--
-- Name: countries__u_country; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX countries__u_country ON countries USING btree (country);


--
-- Name: creatives__u_creative; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX creatives__u_creative ON creatives USING btree (creative);


--
-- Name: device_types__u_device_type; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX device_types__u_device_type ON device_types USING btree (device_type);


--
-- Name: devices__u_device; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX devices__u_device ON devices USING btree (device);


--
-- Name: domains__u_domain; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX domains__u_domain ON domains USING btree (domain);


--
-- Name: event_types__u_event_type; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX event_types__u_event_type ON event_types USING btree (event_type);


--
-- Name: events_event_type_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX events_event_type_id_idx ON events USING btree (event_type_id);


--
-- Name: events_visit_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX events_visit_id_idx ON events USING btree (visit_id);


--
-- Name: experiments__u_experiment; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX experiments__u_experiment ON experiments USING btree (experiment);


--
-- Name: http_methods__u_http_method; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX http_methods__u_http_method ON http_methods USING btree (http_method);


--
-- Name: ip_addresses__u_ip_address; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX ip_addresses__u_ip_address ON ip_addresses USING btree (ip_address);


--
-- Name: ip_lookups_domain_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX ip_lookups_domain_id_idx ON ip_lookups USING btree (domain_id);


--
-- Name: ip_lookups_ip_address_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX ip_lookups_ip_address_id_idx ON ip_lookups USING btree (ip_address_id);


--
-- Name: ip_lookups_location_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX ip_lookups_location_id_idx ON ip_lookups USING btree (location_id);


--
-- Name: keywords__u_keyword; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX keywords__u_keyword ON keywords USING btree (keyword);


--
-- Name: locations_city_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX locations_city_id_idx ON locations USING btree (city_id);


--
-- Name: locations_country_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX locations_country_id_idx ON locations USING btree (country_id);


--
-- Name: locations_region_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX locations_region_id_idx ON locations USING btree (region_id);


--
-- Name: match_types__u_match_type; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX match_types__u_match_type ON match_types USING btree (match_type);


--
-- Name: mediums__u_medium; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX mediums__u_medium ON mediums USING btree (medium);


--
-- Name: mime_types__u_mime_type; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX mime_types__u_mime_type ON mime_types USING btree (mime_type);


--
-- Name: networks__u_network; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX networks__u_network ON networks USING btree (network);


--
-- Name: page_views_click_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX page_views_click_id_idx ON page_views USING btree (click_id);


--
-- Name: page_views_page_revision_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX page_views_page_revision_id_idx ON page_views USING btree (page_revision_id);


--
-- Name: page_views_path_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX page_views_path_id_idx ON page_views USING btree (path_id);


--
-- Name: page_views_query_string_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX page_views_query_string_id_idx ON page_views USING btree (query_string_id);


--
-- Name: page_views_request_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX page_views_request_id_idx ON page_views USING btree (request_id);


--
-- Name: page_views_visit_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX page_views_visit_id_idx ON page_views USING btree (visit_id);


--
-- Name: paths__u_path; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX paths__u_path ON paths USING btree (path);


--
-- Name: placements__u_placement; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX placements__u_placement ON placements USING btree (placement);


--
-- Name: platforms__u_platform; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX platforms__u_platform ON platforms USING btree (platform);


--
-- Name: positions__u_position; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX positions__u_position ON positions USING btree ("position");


--
-- Name: query_strings__u_query_string; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX query_strings__u_query_string ON query_strings USING btree (query_string);


--
-- Name: referers_domain_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX referers_domain_id_idx ON referers USING btree (domain_id);


--
-- Name: referers_domain_id_path_id_query_string_id_attribution_id; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX referers_domain_id_path_id_query_string_id_attribution_id ON referers USING btree (domain_id, path_id, query_string_id, attribution_id);


--
-- Name: referers_path_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX referers_path_id_idx ON referers USING btree (path_id);


--
-- Name: referers_query_string_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX referers_query_string_id_idx ON referers USING btree (query_string_id);


--
-- Name: regions__u_region; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX regions__u_region ON regions USING btree (region);


--
-- Name: search_terms__u_search_term; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX search_terms__u_search_term ON search_terms USING btree (search_term);


--
-- Name: sources__u_source; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX sources__u_source ON sources USING btree (source);


--
-- Name: targets__u_target; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX targets__u_target ON targets USING btree (target);


--
-- Name: user_agent_types__u_user_agent_type; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX user_agent_types__u_user_agent_type ON user_agent_types USING btree (user_agent_type);


--
-- Name: user_agents_browser_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX user_agents_browser_id_idx ON user_agents USING btree (browser_id);


--
-- Name: user_agents_device_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX user_agents_device_id_idx ON user_agents USING btree (device_id);


--
-- Name: user_agents_platform_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX user_agents_platform_id_idx ON user_agents USING btree (platform_id);


--
-- Name: visitors_user_agent_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX visitors_user_agent_id_idx ON visitors USING btree (user_agent_id);


--
-- Name: visits_attribution_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX visits_attribution_id_idx ON visits USING btree (attribution_id);


--
-- Name: visits_cookie_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX visits_cookie_id_idx ON visits USING btree (cookie_id);


--
-- Name: visits_owner_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX visits_owner_id_idx ON visits USING btree (owner_id);


--
-- Name: visits_referer_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX visits_referer_id_idx ON visits USING btree (referer_id);


--
-- Name: visits_visitor_id_idx; Type: INDEX; Schema: traffic; Owner: -; Tablespace: 
--

CREATE INDEX visits_visitor_id_idx ON visits USING btree (visitor_id);


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

CREATE TRIGGER landable_page_revisions__no_update BEFORE UPDATE OF notes, is_minor, page_id, author_id, created_at, ordinal, theme_id, status_code, category_id, redirect_url, body ON page_revisions FOR EACH STATEMENT EXECUTE PROCEDURE tg_disallow();


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
-- Name: category_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_revisions
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
-- Name: theme_id_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY page_revisions
    ADD CONSTRAINT theme_id_fk FOREIGN KEY (theme_id) REFERENCES themes(theme_id);


--
-- Name: updated_author_fk; Type: FK CONSTRAINT; Schema: landable; Owner: -
--

ALTER TABLE ONLY pages
    ADD CONSTRAINT updated_author_fk FOREIGN KEY (updated_by_author_id) REFERENCES authors(author_id);


SET search_path = traffic, pg_catalog;

--
-- Name: accesses_path_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY accesses
    ADD CONSTRAINT accesses_path_id_fkey FOREIGN KEY (path_id) REFERENCES paths(path_id);


--
-- Name: accesses_visitor_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY accesses
    ADD CONSTRAINT accesses_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES visitors(visitor_id);


--
-- Name: attributions_ad_group_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_ad_group_id_fkey FOREIGN KEY (ad_group_id) REFERENCES ad_groups(ad_group_id);


--
-- Name: attributions_ad_type_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_ad_type_id_fkey FOREIGN KEY (ad_type_id) REFERENCES ad_types(ad_type_id);


--
-- Name: attributions_bid_match_type_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_bid_match_type_id_fkey FOREIGN KEY (bid_match_type_id) REFERENCES bid_match_types(bid_match_type_id);


--
-- Name: attributions_campaign_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id);


--
-- Name: attributions_content_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_content_id_fkey FOREIGN KEY (content_id) REFERENCES contents(content_id);


--
-- Name: attributions_creative_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_creative_id_fkey FOREIGN KEY (creative_id) REFERENCES creatives(creative_id);


--
-- Name: attributions_device_type_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_device_type_id_fkey FOREIGN KEY (device_type_id) REFERENCES device_types(device_type_id);


--
-- Name: attributions_experiment_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_experiment_id_fkey FOREIGN KEY (experiment_id) REFERENCES experiments(experiment_id);


--
-- Name: attributions_keyword_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_keyword_id_fkey FOREIGN KEY (keyword_id) REFERENCES keywords(keyword_id);


--
-- Name: attributions_match_type_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_match_type_id_fkey FOREIGN KEY (match_type_id) REFERENCES match_types(match_type_id);


--
-- Name: attributions_medium_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_medium_id_fkey FOREIGN KEY (medium_id) REFERENCES mediums(medium_id);


--
-- Name: attributions_network_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_network_id_fkey FOREIGN KEY (network_id) REFERENCES networks(network_id);


--
-- Name: attributions_placement_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_placement_id_fkey FOREIGN KEY (placement_id) REFERENCES placements(placement_id);


--
-- Name: attributions_position_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_position_id_fkey FOREIGN KEY (position_id) REFERENCES positions(position_id);


--
-- Name: attributions_search_term_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_search_term_id_fkey FOREIGN KEY (search_term_id) REFERENCES search_terms(search_term_id);


--
-- Name: attributions_source_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_source_id_fkey FOREIGN KEY (source_id) REFERENCES sources(source_id);


--
-- Name: attributions_target_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY attributions
    ADD CONSTRAINT attributions_target_id_fkey FOREIGN KEY (target_id) REFERENCES targets(target_id);


--
-- Name: events_event_type_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_event_type_id_fkey FOREIGN KEY (event_type_id) REFERENCES event_types(event_type_id);


--
-- Name: events_visit_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY events
    ADD CONSTRAINT events_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES visits(visit_id);


--
-- Name: ip_lookups_domain_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ip_lookups
    ADD CONSTRAINT ip_lookups_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES domains(domain_id);


--
-- Name: ip_lookups_ip_address_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ip_lookups
    ADD CONSTRAINT ip_lookups_ip_address_id_fkey FOREIGN KEY (ip_address_id) REFERENCES ip_addresses(ip_address_id);


--
-- Name: ip_lookups_location_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ip_lookups
    ADD CONSTRAINT ip_lookups_location_id_fkey FOREIGN KEY (location_id) REFERENCES locations(location_id);


--
-- Name: locations_city_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_city_id_fkey FOREIGN KEY (city_id) REFERENCES cities(city_id);


--
-- Name: locations_country_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_country_id_fkey FOREIGN KEY (country_id) REFERENCES countries(country_id);


--
-- Name: locations_region_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY locations
    ADD CONSTRAINT locations_region_id_fkey FOREIGN KEY (region_id) REFERENCES regions(region_id);


--
-- Name: ownerships_cookie_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_cookie_id_fkey FOREIGN KEY (cookie_id) REFERENCES cookies(cookie_id);


--
-- Name: ownerships_owner_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY ownerships
    ADD CONSTRAINT ownerships_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES owners(owner_id);


--
-- Name: page_views_http_method_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_http_method_id_fkey FOREIGN KEY (http_method_id) REFERENCES http_methods(http_method_id);


--
-- Name: page_views_mime_type_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_mime_type_id_fkey FOREIGN KEY (mime_type_id) REFERENCES mime_types(mime_type_id);


--
-- Name: page_views_page_revision_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_page_revision_id_fkey FOREIGN KEY (page_revision_id) REFERENCES landable.page_revisions(page_revision_id);


--
-- Name: page_views_path_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_path_id_fkey FOREIGN KEY (path_id) REFERENCES paths(path_id);


--
-- Name: page_views_query_string_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_query_string_id_fkey FOREIGN KEY (query_string_id) REFERENCES query_strings(query_string_id);


--
-- Name: page_views_visit_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY page_views
    ADD CONSTRAINT page_views_visit_id_fkey FOREIGN KEY (visit_id) REFERENCES visits(visit_id);


--
-- Name: referers_attribution_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY referers
    ADD CONSTRAINT referers_attribution_id_fkey FOREIGN KEY (attribution_id) REFERENCES attributions(attribution_id);


--
-- Name: referers_domain_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY referers
    ADD CONSTRAINT referers_domain_id_fkey FOREIGN KEY (domain_id) REFERENCES domains(domain_id);


--
-- Name: referers_path_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY referers
    ADD CONSTRAINT referers_path_id_fkey FOREIGN KEY (path_id) REFERENCES paths(path_id);


--
-- Name: referers_query_string_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY referers
    ADD CONSTRAINT referers_query_string_id_fkey FOREIGN KEY (query_string_id) REFERENCES query_strings(query_string_id);


--
-- Name: user_agents_browser_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agents_browser_id_fkey FOREIGN KEY (browser_id) REFERENCES browsers(browser_id);


--
-- Name: user_agents_device_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agents_device_id_fkey FOREIGN KEY (device_id) REFERENCES devices(device_id);


--
-- Name: user_agents_platform_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agents_platform_id_fkey FOREIGN KEY (platform_id) REFERENCES platforms(platform_id);


--
-- Name: user_agents_user_agent_type_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY user_agents
    ADD CONSTRAINT user_agents_user_agent_type_id_fkey FOREIGN KEY (user_agent_type_id) REFERENCES user_agent_types(user_agent_type_id);


--
-- Name: visitors_ip_address_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visitors
    ADD CONSTRAINT visitors_ip_address_id_fkey FOREIGN KEY (ip_address_id) REFERENCES ip_addresses(ip_address_id);


--
-- Name: visitors_user_agent_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visitors
    ADD CONSTRAINT visitors_user_agent_id_fkey FOREIGN KEY (user_agent_id) REFERENCES user_agents(user_agent_id);


--
-- Name: visits_attribution_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT visits_attribution_id_fkey FOREIGN KEY (attribution_id) REFERENCES attributions(attribution_id);


--
-- Name: visits_cookie_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT visits_cookie_id_fkey FOREIGN KEY (cookie_id) REFERENCES cookies(cookie_id);


--
-- Name: visits_owner_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT visits_owner_id_fkey FOREIGN KEY (owner_id) REFERENCES owners(owner_id);


--
-- Name: visits_referer_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT visits_referer_id_fkey FOREIGN KEY (referer_id) REFERENCES referers(referer_id);


--
-- Name: visits_visitor_id_fkey; Type: FK CONSTRAINT; Schema: traffic; Owner: -
--

ALTER TABLE ONLY visits
    ADD CONSTRAINT visits_visitor_id_fkey FOREIGN KEY (visitor_id) REFERENCES visitors(visitor_id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO schema_migrations (version) VALUES ('20130510221424');

INSERT INTO schema_migrations (version) VALUES ('20130909182713');

INSERT INTO schema_migrations (version) VALUES ('20130909182715');

INSERT INTO schema_migrations (version) VALUES ('20130909191153');

INSERT INTO schema_migrations (version) VALUES ('20131002220041');

INSERT INTO schema_migrations (version) VALUES ('20131008164204');

INSERT INTO schema_migrations (version) VALUES ('20131008193544');

INSERT INTO schema_migrations (version) VALUES ('20131028145652');

INSERT INTO schema_migrations (version) VALUES ('20131101213623');

INSERT INTO schema_migrations (version) VALUES ('20131104224120');

INSERT INTO schema_migrations (version) VALUES ('20131106185946');

INSERT INTO schema_migrations (version) VALUES ('20131106193021');

INSERT INTO schema_migrations (version) VALUES ('20131108212501');

INSERT INTO schema_migrations (version) VALUES ('20131115152418');

INSERT INTO schema_migrations (version) VALUES ('20131121150902');

INSERT INTO schema_migrations (version) VALUES ('20131203165916');

INSERT INTO schema_migrations (version) VALUES ('20131204160433');

INSERT INTO schema_migrations (version) VALUES ('20131213141218');

INSERT INTO schema_migrations (version) VALUES ('20131216214027');
