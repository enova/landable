class AddTrafficSchema < ActiveRecord::Migration
  # "owners"."owner" records your application's user/account/person identifier.
  # Change the following line if your identifiers' data type is not INTEGER.

  OWNER_DATA_TYPE = 'integer'

  QUERY_PARAMS = %w[
    ad_type
    bid_match_type
    campaign
    content
    creative
    device_type
    keyword
    match_type
    medium
    network
    placement
    position
    search_term
    source
    target]

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
      t.create_lookup_tables *QUERY_PARAMS.map(&:pluralize)

      # User Agent
      t.create_lookup_tables :user_agent_types, :browsers, :devices, :platforms
      t.create_lookup_tables :domains, :paths

      t.create_lookup_table  :event_types

      t.create_lookup_table  :ip_addresses, lookup_type: :inet
    end

    execute <<-SQL
      SET search_path TO traffic,public;

      INSERT INTO user_agent_types (user_agent_type) VALUES ('crawl'), ('ping'), ('scan'), ('scrape'), ('user');

      CREATE TABLE user_agents (
          user_agent_id      SERIAL      PRIMARY KEY

        , user_agent_type_id INTEGER     NOT NULL    REFERENCES user_agent_types

        , user_agent         TEXT        NOT NULL    UNIQUE

        , browser_id         INTEGER                 REFERENCES browsers
        , browser_version    TEXT
        , device_id          INTEGER                 REFERENCES devices
        , platform_id        INTEGER                 REFERENCES platforms

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()
      );

      CREATE TABLE attributions (
          attribution_id     SERIAL      PRIMARY KEY

        , #{QUERY_PARAMS.map { |name| "%s INTEGER REFERENCES %s" % [name.foreign_key, name.pluralize] }.join(',') }

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()

        , UNIQUE (#{QUERY_PARAMS.map(&:foreign_key).join(',')})
      );

      -- TODO: is query needed?
      CREATE TABLE referers (
          referer_id         SERIAL      PRIMARY KEY

        , domain_id          INTEGER     NOT NULL    REFERENCES domains
        , path_id            INTEGER     NOT NULL    REFERENCES paths

        , UNIQUE (domain_id, path_id)
      );

      CREATE TABLE ip_lookups (
          ip_lookup_id       SERIAL       PRIMARY KEY

        , ip_address_id      INTEGER      NOT NULL    REFERENCES ip_addresses

        , domain_id          INTEGER                  REFERENCES domains
        , latitude           REAL
        , longitude          REAL

        , created_at         TIMESTAMPTZ  NOT NULL    DEFAULT NOW()
      );


      -- User Tracking

      CREATE TABLE cookies (
          cookie_id          UUID        PRIMARY KEY DEFAULT uuid_generate_v4()
      );

      CREATE TABLE owners (
          owner_id           INTEGER     PRIMARY KEY
        , owner              #{OWNER_DATA_TYPE}     NOT NULL    UNIQUE
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

      CREATE TABLE visits (
          visit_id           SERIAL      PRIMARY KEY

        , cookie_id          UUID        NOT NULL    REFERENCES cookies
        , visitor_id         INTEGER     NOT NULL    REFERENCES visitors

        , attribution_id     INTEGER     NOT NULL    REFERENCES attributions

        , referer_id         INTEGER                 REFERENCES referers
        , owner_id           INTEGER                 REFERENCES owners

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()
      );

      CREATE TABLE page_views (
          page_view_id       SERIAL      PRIMARY KEY

        , visit_id           INTEGER     NOT NULL    REFERENCES visits
        , request_id         UUID        NOT NULL
        , path_id            INTEGER     NOT NULL    REFERENCES paths
        , page_revision_id   UUID                    REFERENCES landable.page_revisions

        , created_at         TIMESTAMPTZ NOT NULL    DEFAULT NOW()
      );

      CREATE TABLE events (
          event_id           SERIAL      PRIMARY KEY
        , event_type_id      INTEGER     NOT NULL     REFERENCES event_types

        , visit_id           INTEGER     NOT NULL     REFERENCES visits

        , created_at         TIMESTAMPTZ NOT NULL     DEFAULT NOW()
      );


      -- visit frequency
      CREATE TABLE accesses (
          access_id          SERIAL      PRIMARY KEY

        , request_id         UUID        NOT NULL
        , path_id            INTEGER     NOT NULL    REFERENCES paths
        , visitor_id         INTEGER     NOT NULL    REFERENCES visitors

        , last_accessed_at   TIMESTAMPTZ NOT NULL    DEFAULT NOW()

        , UNIQUE (path_id, visitor_id)
      );

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
