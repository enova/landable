module Landable
  module Traffic
    class UserTracker < Tracker
      def track
        load
        cookie
        record_visit
      end

      def load
        hash = session[:landable] || {}

        @cookie_id        = cookies[:landable]

        @visit_id         = hash[KEYS[:visit_id]]
        @last_visit_time  = hash[KEYS[:visit_time]].to_time
        @visitor_id       = hash[KEYS[:visitor_id]]
        @visitor_hash     = hash[KEYS[:visitor_hash]]
        @attribution_hash = hash[KEYS[:attribution_hash]]
        @referer_hash     = hash[KEYS[:referer_hash]]
      end

      def record_page_view
        PageView.create do |p|
          p.http_method  = request.method
          p.mime_type    = request.format.to_s
          p.path         = request.path
          p.query_string = untracked_parameters.to_query
          p.request_id   = request.uuid

          p.click_id     = tracking_parameters["click_id"]

          p.http_status  = response.status

          p.visit_id     = @visit_id

          p.response_time = ( Time.now - @start_time ) * 1000
        end
      end

      def save
        record_page_view

        session[:landable] = {
          KEYS[:visit_id]         => @visit_id,
          KEYS[:visit_time]       => Time.current,
          KEYS[:visitor_id]       => @visitor_id,
          KEYS[:visitor_hash]     => visitor_hash,
          KEYS[:attribution_hash] => attribution? ? attribution_hash : @attribution_hash,
          KEYS[:referer_hash]     => referer_changed? ? referer_hash : @referer_hash
        }
      end

      def identify(identifier)
        visit = Visit.find(@visit_id)
        owner = Owner.where(owner: identifier).first_or_create

        visit.owner = owner
        visit.save!

        Ownership.where(cookie_id: @cookie_id, owner: owner).first_or_create
      end
    end
  end
end
