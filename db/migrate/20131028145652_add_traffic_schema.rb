class AddTrafficSchema < ActiveRecord::Migration
  # "owners"."owner" records your application's user/account/person identifier.
  # Change the following line if your identifiers' data type is not INTEGER.

  OWNER_TYPE = 'INTEGER'

  QUERY_PARAMS = %w[
    ad_type
    ad_group
    bid_match_type
    campaign
    content
    creative
    device_type
    experiment
    keyword
    match_type
    medium
    network
    placement
    position
    search_term
    source
    target
  ]

  def up
    # Resources
    #
    # Measuring and Tracking Success: http://moz.com/beginners-guide-to-seo/measuring-and-tracking-success

    # Query String
    #
    # keywords: http://cyrusshepard.com/7-fantastic-seo-tips-for-googles-not-provided-keywords/

    execute "CREATE SCHEMA traffic;"

    with_options schema: 'traffic' do |t|
      # Query Params
      t.create_lookup_tables(*QUERY_PARAMS.map(&:pluralize))

      # User Agent
      t.create_lookup_tables :user_agent_types, :browsers, :devices, :platforms

      # HTTP
      t.create_lookup_tables :domains, :paths, :query_strings
      t.create_lookup_tables :http_methods, :mime_types

      t.create_lookup_table  :event_types

      # IP / Geolocation
      t.create_lookup_table  :ip_addresses, lookup_type: :inet
      t.create_lookup_tables :countries, :regions, :cities
    end

    execute <<-SQL
      SET search_path TO traffic,public;

      ALTER TABLE mime_types       ALTER COLUMN mime_type_id       SET DATA TYPE SMALLINT;
      ALTER TABLE http_methods     ALTER COLUMN http_method_id     SET DATA TYPE SMALLINT;

      ALTER TABLE user_agent_types ALTER COLUMN user_agent_type_id SET DATA TYPE SMALLINT;
      ALTER TABLE platforms        ALTER COLUMN platform_id        SET DATA TYPE SMALLINT;
      ALTER TABLE browsers         ALTER COLUMN browser_id         SET DATA TYPE SMALLINT;

      INSERT INTO user_agent_types (user_agent_type) VALUES ('user'), ('ping'), ('crawl'), ('scrape'), ('scan');

      CREATE TABLE user_agents (
          user_agent_id      SERIAL      PRIMARY KEY

        , user_agent_type_id SMALLINT                REFERENCES user_agent_types

        , device_id          INTEGER                 REFERENCES devices
        , platform_id        SMALLINT                REFERENCES platforms
        , browser_id         SMALLINT                REFERENCES browsers
        , browser_version    TEXT

        , user_agent         TEXT        NOT NULL    UNIQUE

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()
      );

      CREATE INDEX ON user_agents (device_id);
      CREATE INDEX ON user_agents (platform_id);
      CREATE INDEX ON user_agents (browser_id);

      ALTER TABLE ad_types        ALTER COLUMN ad_type_id        SET DATA TYPE SMALLINT;
      ALTER TABLE bid_match_types ALTER COLUMN bid_match_type_id SET DATA TYPE SMALLINT;
      ALTER TABLE device_types    ALTER COLUMN device_type_id    SET DATA TYPE SMALLINT;
      ALTER TABLE match_types     ALTER COLUMN match_type_id     SET DATA TYPE SMALLINT;
      ALTER TABLE positions       ALTER COLUMN position_id       SET DATA TYPE SMALLINT;

      -- TODO: aceid AdWords Campaign Experiment ID
      CREATE TABLE attributions (
          attribution_id     SERIAL      PRIMARY KEY

        , #{QUERY_PARAMS.map { |name| "%s INTEGER REFERENCES %s" % [name.foreign_key, name.pluralize] }.join(',') }

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()

        , UNIQUE (#{QUERY_PARAMS.map(&:foreign_key).join(',')})
      );

      ALTER TABLE attributions
          ALTER COLUMN ad_type_id        SET DATA TYPE SMALLINT
        , ALTER COLUMN bid_match_type_id SET DATA TYPE SMALLINT
        , ALTER COLUMN device_type_id    SET DATA TYPE SMALLINT
        , ALTER COLUMN match_type_id     SET DATA TYPE SMALLINT
        , ALTER COLUMN position_id       SET DATA TYPE SMALLINT
      ;

      #{QUERY_PARAMS.map { |p| "CREATE INDEX ON attributions (#{p.foreign_key});" }.join("\n")}

      CREATE TABLE referers (
          referer_id         SERIAL     PRIMARY KEY

        , domain_id          INTEGER    NOT NULL     REFERENCES domains
        , path_id            INTEGER    NOT NULL     REFERENCES paths
        , query_string_id    INTEGER    NOT NULL     REFERENCES query_strings

        , attribution_id     INTEGER    NOT NULL     REFERENCES attributions

        , UNIQUE (domain_id, path_id, query_string_id)
      );

      CREATE INDEX ON referers (domain_id);
      CREATE INDEX ON referers (path_id);
      CREATE INDEX ON referers (query_string_id);

      CREATE TABLE locations (
          location_id        SERIAL      PRIMARY KEY

        , country_id         INTEGER                 REFERENCES countries
        , region_id          INTEGER                 REFERENCES regions
        , city_id            INTEGER                 REFERENCES cities

        , UNIQUE (country_id, region_id, city_id)
      );

      CREATE INDEX ON locations (country_id);
      CREATE INDEX ON locations (region_id);
      CREATE INDEX ON locations (city_id);

      CREATE TABLE ip_lookups (
          ip_lookup_id       SERIAL      PRIMARY KEY

        , ip_address_id      INTEGER     NOT NULL    REFERENCES ip_addresses
        , domain_id          INTEGER                 REFERENCES domains
        , location_id        INTEGER                 REFERENCES locations

        , latitude           REAL
        , longitude          REAL

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()
      );

      CREATE INDEX ON ip_lookups (ip_address_id);
      CREATE INDEX ON ip_lookups (domain_id);
      CREATE INDEX ON ip_lookups (location_id);


      -- User Traffic

      CREATE TABLE cookies (
          cookie_id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4()
      );

      CREATE TABLE owners (
          owner_id           INTEGER     PRIMARY KEY
        , owner            #{OWNER_TYPE} NOT NULL UNIQUE
      );

      CREATE TABLE ownerships (
          owner_id           INTEGER     NOT NULL    REFERENCES owners
        , cookie_id          UUID        NOT NULL    REFERENCES cookies

        , PRIMARY KEY (owner_id, cookie_id)
      );

      CREATE TABLE visitors (
          visitor_id         SERIAL      PRIMARY KEY

        , ip_address_id      INTEGER     NOT NULL    REFERENCES ip_addresses
        , user_agent_id      INTEGER     NOT NULL    REFERENCES user_agents

        , UNIQUE (ip_address_id, user_agent_id)
      );

      CREATE INDEX ON visitors (user_agent_id);

      CREATE TABLE visits (
          visit_id           SERIAL      PRIMARY KEY

        , cookie_id          UUID        NOT NULL    REFERENCES cookies

        , visitor_id         INTEGER     NOT NULL    REFERENCES visitors
        , attribution_id     INTEGER     NOT NULL    REFERENCES attributions

        , referer_id         INTEGER                 REFERENCES referers
        , owner_id           INTEGER                 REFERENCES owners

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()
      );

      CREATE INDEX ON visits (cookie_id);
      CREATE INDEX ON visits (visitor_id);
      CREATE INDEX ON visits (attribution_id);
      CREATE INDEX ON visits (referer_id);
      CREATE INDEX ON visits (owner_id);

      CREATE TABLE page_views (
          page_view_id       SERIAL      PRIMARY KEY

        , visit_id           INTEGER     NOT NULL    REFERENCES visits
        , path_id            INTEGER     NOT NULL    REFERENCES paths
        , query_string_id    INTEGER     NOT NULL    REFERENCES query_strings

        , mime_type_id       SMALLINT    NOT NULL    REFERENCES mime_types
        , http_method_id     SMALLINT    NOT NULL    REFERENCES http_methods

        , page_revision_id   UUID                    REFERENCES landable.page_revisions
        , request_id         UUID

        , click_id           TEXT

        , content_length     INTEGER
        , http_status        INTEGER

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()
      );

      CREATE INDEX ON page_views (visit_id);
      CREATE INDEX ON page_views (path_id);
      CREATE INDEX ON page_views (query_string_id);
      CREATE INDEX ON page_views (page_revision_id);
      CREATE INDEX ON page_views (request_id);
      CREATE INDEX ON page_views (click_id);

      CREATE TABLE events (
          event_id           SERIAL      PRIMARY KEY

        , event_type_id      INTEGER     NOT NULL     REFERENCES event_types
        , visit_id           INTEGER     NOT NULL     REFERENCES visits

        , created_at         TIMESTAMPTZ NOT NULL     DEFAULT NOW()
      );

      CREATE INDEX ON events (event_type_id);
      CREATE INDEX ON events (visit_id);


      -- TODO: visit frequency
      CREATE TABLE accesses (
          access_id          SERIAL      PRIMARY KEY

        , path_id            INTEGER     NOT NULL    REFERENCES paths
        , visitor_id         INTEGER     NOT NULL    REFERENCES visitors

        , last_accessed_at   TIMESTAMPTZ NOT NULL    DEFAULT NOW()

        , UNIQUE (path_id, visitor_id)
      );

      CREATE INDEX ON accesses (visitor_id);

      INSERT INTO bid_match_types (bid_match_type) VALUES ('bidded broad'), ('bidded content'), ('bidded exact'), ('bidded phrase');
      INSERT INTO device_types    (device_type)    VALUES ('computer'), ('mobile'), ('tablet');
      INSERT INTO match_types     (match_type)     VALUES ('broad'), ('phrase'), ('exact');
      INSERT INTO networks        (network)        VALUES ('google_search'), ('search_partner'), ('display_network');

      -- Views
      -- * visits from non-user user_agents
      -- * visits from real user_agents on ips with non-user visits
    SQL
  end
end
