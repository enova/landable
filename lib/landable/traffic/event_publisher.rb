module Landable
  class EventPublisher
    attr_accessor :page_view, :visit, :tracker, :event

    def initialize(tracker, page_view, meta = {})
      event_type = event_mapping[page_view.path]
      if event_type.kind_of?(Hash)
        request_type = page_view.http_method
        event_type = event_type[request_type]
      end
      return unless event_type
      @page_view = page_view

      @tracker = tracker
      @visit = tracker.visit
      @event = tracker.create_event(event_type, meta)
    end

    def enabled?
      @enabled ||= Landable.configuration.hutch_enable && defined?(Hutch) && Hutch.connected?
    end

    def queue
      @queue ||= Landable.configuration.hutch_queue
    end

    def event_mapping
      @event_mapping ||= Landable.configuration.event_mapping
    end

    def application_name
      @application_name ||= Landable.configuration.application_name
    end

    def publish
      return unless enabled? && @event
      Hutch.publish(queue, message)
    end

    def get_owner
      if visit.owner_id.present?
        owner = Landable::Traffic::Owner.find(visit.owner_id).owner
      end
    end

    def message
      referer = visit.referer
      attribution = visit.attribution
      { event_id: event.id,
        event: event.event_type,
        request_type: page_view.http_method,
        brand: application_name,
        visit_id: visit.id,
        created_at: visit.created_at,
        cookie_id: visit.cookie_id,
        owner_id: visit.owner_id,
        owner: get_owner,
        referer_id: referer.try(:id),
        domain_id: referer.try(:domain_id),
        domain: referer.try(:domain),
        ip_address_id: tracker.ip_address.id,
        ip_address: tracker.ip_address.ip_address.to_s,
        user_agent_id: tracker.user_agent.id,
        user_agent: tracker.user_agent.user_agent,
        user_agent_type_id: tracker.user_agent.user_agent_type.try(:id),
        user_agent_type: tracker.user_agent.user_agent_type,
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
        page_view_id: @page_view.page_view_id,
        path_id: @page_view.path_id,
        path: @page_view.path
      }
    end
  end
end
