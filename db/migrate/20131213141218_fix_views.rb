class FixViews < ActiveRecord::Migration
  def up
    execute <<-SQL
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
        traffic.visits v
        JOIN traffic.visitors_v vs USING(visitor_id)
        LEFT OUTER JOIN traffic.owners o USING(owner_id)
        LEFT OUTER JOIN traffic.events e USING(visit_id)
        LEFT OUTER JOIN traffic.event_types et USING(event_type_id);

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
        , pv.created_at
      FROM
        traffic.page_views pv
        JOIN traffic.paths p USING(path_id)
        LEFT OUTER JOIN traffic.query_strings qs USING(query_string_id)
        LEFT OUTER JOIN traffic.mime_types mt USING(mime_type_id)
        LEFT OUTER JOIN traffic.http_methods USING(http_method_id)
        LEFT OUTER JOIN landable.page_revisions pr USING(page_revision_id);
    SQL
  end
end
