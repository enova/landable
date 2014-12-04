class VisitsReportingGeneralized < ActiveRecord::Migration
  def up
    execute <<-SQL
    DROP VIEW IF EXISTS #{Landable.configuration.database_schema_prefix}landable_traffic.visits_denormalized;
    CREATE OR REPLACE VIEW #{Landable.configuration.database_schema_prefix}landable_traffic.visits_denormalized
    AS
    select
        v.visit_id,
        vi.visitor_id,
        o."owner" as account_id,
        ip.ip_address,
        uat.user_agent_type as visitor_user_agent_type,
        de.device as visitor_device,
        pla.platform as visitor_plaform,
        b.browser as visitor_browser,
        ua.browser_version as visitor_browser_version,
        ua.user_agent as visitor_user_agent,
        d."domain" as referer_domain,
        p.path as referer_path,
        s.source as attribution_source,
        c.campaign as attribution_campaign,
        at.ad_type as attribution_ad_type,
        bmt.bid_match_type as attribution_bid_match_type,
        co.content as attribution_content,
        cr.creative as attribution_creative,
        dt.device_type as attribution_device_type,
        e.experiment as attribution_experiment,
        k.keyword as attribution_keyword,
        mt.match_type as attribution_match_type,
        m.medium as attribution_medium,
        n.network as attribution_network,
        pl.placement as attribution_placement,
        po."position" as attribution_position,
        st.search_term as attribution_search_term,
        t.target as attribution_target,
        v.created_at as visit_created_at
      from
       #{Landable.configuration.database_schema_prefix}_landable_traffic.visits v
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.owners o on o.owner_id = v.owner_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.visitors vi on vi.visitor_id = v.visitor_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.user_agents ua on ua.user_agent_id = vi.user_agent_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.user_agent_types uat on uat.user_agent_type_id = ua.user_agent_type_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.devices de on de.device_id = ua.device_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.platforms pla on pla.platform_id = ua.platform_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.browsers b on b.browser_id = ua.browser_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.ip_addresses ip on ip.ip_address_id = vi.ip_address_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.referers r on r.referer_id = v.referer_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.domains d on d.domain_id = r.domain_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.paths p on p.path_id = r.path_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.attributions a on a.attribution_id = v.attribution_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.sources s on s.source_id = a.source_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.campaigns c on c.campaign_id = a.campaign_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.ad_types at on at.ad_type_id = a.ad_type_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.bid_match_types bmt on bmt.bid_match_type_id = a.bid_match_type_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.contents co on co.content_id = a.content_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.creatives cr on cr.creative_id = a.creative_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.device_types dt on dt.device_type_id = a.device_type_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.experiments e on e.experiment_id = a.experiment_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.keywords k on k.keyword_id = a.keyword_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.match_types mt on mt.match_type_id = a.match_type_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.mediums m on m.medium_id = a.medium_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.networks n on n.network_id = a.network_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.placements pl on pl.placement_id = a.placement_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.positions po on po.position_id = a.position_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.search_terms st on st.search_term_id = a.search_term_id
       left join #{Landable.configuration.database_schema_prefix}landable_traffic.targets t on t.target_id = a.target_id

	    COMMENT ON VIEW #{Landable.configuration.database_schema_prefix}landable_traffic.visits_denormalized IS $$ The view visits_denormalized is a collection of data commonly used to describe a visit.$$;
    SQL
  end
end