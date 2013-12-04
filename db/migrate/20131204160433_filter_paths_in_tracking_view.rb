class FilterPathsInTrackingView < ActiveRecord::Migration
  def up
    execute <<-SQL
      DROP VIEW traffic.tracking;

      CREATE VIEW traffic.tracking AS
      SELECT
        customer_id
        , v.visit_id as visit
        , cookie
        , ip_address
        , user_agent
        , user_agent_type
        , device
        , platform
        , browser
        , browser_version
        , do_not_track
        , v.created_at as visit_created_at
        , path
        , query_string
        , mime_type
        , http_method
        , page_revision
        , content_length
        , http_status
        , request_id
        , click_id
        , pv.created_at AS page_view_created_at
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
        , av.created_at AS attribution_created_at
      FROM
        traffic.visits_v v
        JOIN traffic.page_views_v pv USING(visit_id)
        JOIN traffic.attributions_v av USING(attribution_id)
      WHERE
            path NOT LIKE '%stylesheets%'
        AND path NOT LIKE '%javascript%'
        AND path NOT LIKE '%images%';
    SQL
  end
end
