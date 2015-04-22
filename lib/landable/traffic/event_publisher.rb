module Landable
  class EventPublisher
    attr_accessor :page_view, :visit, :event_type, :ampq_messaging_service

    def initialize(page_view)
      event_type = ampq_event_mapping[page_view.path]
      if event_type.is_a?(Hash)
        request_type = page_view.http_method
        event_type = event_type[request_type]
      end

      return unless event_type
      @page_view = page_view

      @visit = page_view.visit
      @event_type = event_type
    end

    def ampq_enabled?
      @ampq_enabled ||= Landable.configuration.ampq_enabled
    end

    def ampq_event_mapping
      @ampq_event_mapping ||= Landable.configuration.ampq_event_mapping
    end

    def ampq_application_name
      @ampq_application_name ||= Landable.configuration.ampq_application_name
    end

    def ampq_messaging_service
      @ampq_messaging_service ||= Landable.configuration.ampq_messaging_service
    end

    def publish
      return unless ampq_enabled? && ampq_messaging_service.present?
      ampq_messaging_service.publish(message)
    end

    def message
      attribution = visit.try(:attribution)
      referer = visit.try(:referer)
      visitor = visit.visitor
      user_agent = visitor.try(:raw_user_agent)
      user_agent_type = user_agent.try(:raw_user_agent_type)
      {
        brand: ampq_application_name,
        visit_id: visit.id,
        event: event_type.to_s,
        page_view_id: page_view.page_view_id,
        request_type: page_view.http_method,
        created_at: page_view.created_at,
        cookie_id: visit.cookie_id,
        owner_id: visit.try(:owner_id),
        owner: visit.try(:owner).try(:owner),
        referer_id: referer.try(:id),
        domain_id: referer.try(:domain_id),
        domain: referer.try(:domain),
        ip_address_id: visitor.try(:ip_address_id),
        ip_address: visitor.try(:ip_address).try(:to_s),
        user_agent_id: user_agent.try(:id),
        user_agent: user_agent.try(:user_agent),
        user_agent_type_id: user_agent_type.try(:id),
        user_agent_type: user_agent_type.try(:user_agent_type),
        attribution_id: attribution.try(:id),
        ad_group_id: attribution.try(:ad_group_id),
        ad_group: attribution.try(:ad_group),
        ad_type_id: attribution.try(:ad_type_id),
        ad_type: attribution.try(:ad_type),
        bid_match_type_id: attribution.try(:bid_match_type_id),
        bid_match_type: attribution.try(:bid_match_type),
        campaign_id: attribution.try(:campaign_id),
        campaign: attribution.try(:campaign),
        content_id: attribution.try(:content_id),
        content: attribution.try(:content),
        creative_id: attribution.try(:creative_id),
        creative: attribution.try(:creative),
        device_type_id: attribution.try(:device_type_id),
        device_type: attribution.try(:device_type),
        experiment_id: attribution.try(:experiment_id),
        experiment: attribution.try(:experiment),
        keyword_id: attribution.try(:keyword_id),
        keyword: attribution.try(:keyword),
        match_type_id: attribution.try(:match_type_id),
        match_type: attribution.try(:match_type),
        medium_id: attribution.try(:medium_id),
        medium: attribution.try(:medium),
        network_id: attribution.try(:network_id),
        network: attribution.try(:network),
        placement_id: attribution.try(:placement_id),
        placement: attribution.try(:placement),
        position_id: attribution.try(:position_id),
        position: attribution.try(:position),
        search_term_id: attribution.try(:search_term_id),
        search_term: attribution.try(:search_term),
        source_id: attribution.try(:source_id),
        source: attribution.try(:source),
        target_id: attribution.try(:target_id),
        target: attribution.try(:target),
        path_id: page_view.path_id,
        path: page_view.path
      }
    end
  end
end
