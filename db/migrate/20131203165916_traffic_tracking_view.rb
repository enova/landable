class TrafficTrackingView < ActiveRecord::Migration
  def change
    execute <<-SQL
      DROP VIEW traffic.page_views_v;

      CREATE VIEW traffic.page_views_v AS
      SELECT 
        pv.page_view_id
        , pv.visit_id
        , p.path
        , qs.query_string
        , mt.mime_type
        , http_methods.http_method
        , pr.ordinal AS page_revision
        , pv.content_length
        , pv.http_status
        , pv.request_id
        , pv.click_id
        , pv.created_at
      FROM traffic.page_views pv
         JOIN traffic.visits v USING (visit_id)
         JOIN traffic.paths p USING (path_id)
         LEFT JOIN traffic.query_strings qs USING (query_string_id)
         LEFT JOIN traffic.mime_types mt USING (mime_type_id)
         LEFT JOIN traffic.http_methods USING (http_method_id)
         LEFT JOIN landable.page_revisions pr USING (page_revision_id);

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
        JOIN traffic.attributions_v av USING(attribution_id);
    SQL
  end
end
