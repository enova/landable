class DenormalizedTrafficViews < Landable::Migration
  def up
    execute <<-SQL
      SET search_path TO traffic, public;

      -- Visitors
      CREATE OR REPLACE VIEW traffic.visitors_v AS
      SELECT
          visitor_id
        , ip_address
        , user_agent
        , user_agent_type
        , device
        , platform
        , browser
        , browser_version
      FROM
        visitors v  
        JOIN ip_addresses USING(ip_address_id)
        JOIN user_agents ua USING(user_agent_id)
        LEFT OUTER JOIN user_agent_types uat USING(user_agent_type_id)
        LEFT OUTER JOIN devices d USING(device_id)
        LEFT OUTER JOIN platforms p USING(platform_id)
        LEFT OUTER JOIN browsers b USING(browser_id);

      -- Attributions
      CREATE OR REPLACE VIEW traffic.attributions_v AS
      SELECT
          attribution_id
        , ad_type
        , ad_group
        , bid_match_type
        , campaign
        , content
        , creative
        , device_type
        , experiment
        , keyword
        , match_type
        , medium
        , network
        , placement
        , position
        , search_term
        , source
        , target
        , created_at
      FROM
        attributions a
        LEFT OUTER JOIN ad_types at USING(ad_type_id)
        LEFT OUTER JOIN ad_groups ag USING(ad_group_id)
        LEFT OUTER JOIN bid_match_types bmt USING(bid_match_type_id)
        LEFT OUTER JOIN campaigns c USING(campaign_id)
        LEFT OUTER JOIN contents cs USING(content_id)
        LEFT OUTER JOIN creatives ct USING(creative_id)
        LEFT OUTER JOIN device_types dt USING(device_type_id)
        LEFT OUTER JOIN experiments e USING(experiment_id)
        LEFT OUTER JOIN keywords k USING(keyword_id)
        LEFT OUTER JOIN match_types mt USING(match_type_id)
        LEFT OUTER JOIN mediums m USING(medium_id)
        LEFT OUTER JOIN networks n USING(network_id)
        LEFT OUTER JOIN placements p USING(placement_id)
        LEFT OUTER JOIN positions ps USING(position_id)
        LEFT OUTER JOIN search_terms st USING(search_term_id)
        LEFT OUTER JOIN sources s USING(source_id)
        LEFT OUTER JOIN targets t USING(target_id);

      -- Visits
      CREATE OR REPLACE VIEW traffic.visits_v AS
      SELECT
          visit_id
        , attribution_id
        , cookie_id AS cookie
        , ip_address
        , user_agent
        , user_agent_type
        , device
        , platform
        , browser
        , browser_version
        , owner AS customer_id
        , do_not_track
        , v.created_at
        , event_type
      FROM
        visits v
        JOIN attributions a USING(attribution_id)
        JOIN visitors_v vs USING(visitor_id)
        LEFT OUTER JOIN owners o USING(owner_id)
        LEFT OUTER JOIN events e USING(visit_id)
        LEFT OUTER JOIN event_types et USING(event_type_id);

      -- Page Views
      CREATE OR REPLACE VIEW traffic.page_views_v AS
      SELECT
          page_view_id
        , visit_id
        , p.path
        , query_string
        , mime_type
        , http_method
        , ordinal AS page_revision
        , content_length
        , http_status
        , request_id
        , click_id
      FROM
        page_views pv
        JOIN visits v USING(visit_id)
        JOIN paths p USING(path_id)
        LEFT OUTER JOIN query_strings qs USING(query_string_id)
        LEFT OUTER JOIN mime_types mt USING(mime_type_id)
        LEFT OUTER JOIN http_methods USING(http_method_id)
        JOIN landable.page_revisions pr USING(page_revision_id);

      -- Accesses
      CREATE OR REPLACE VIEW traffic.accesses_v AS
      SELECT 
          access_id
        , path
        , visitor_id
        , ip_address
        , user_agent_type
        , device
        , platform
        , browser
        , browser_version
        , user_agent
      FROM
        traffic.accesses a
        JOIN traffic.paths p USING(path_id)
        JOIN traffic.visitors_v v USING(visitor_id);
    SQL
  end
end
