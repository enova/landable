module Landable
  module Tracking
    class UserTracker < Tracker
      def track
        load
        cookie
        record_visit
        record_page_view
        save
      end

      def load
        hash = session[:landable] || {}

        @cookie_id        = cookies[:landable]

        @visit_id         = hash[VISIT_ID]
        @last_visit_time  = hash[VISIT_TIME]
        @visitor_id       = hash[VISITOR_ID]
        @visitor_hash     = hash[VISITOR_HASH]
        @attribution_hash = hash[ATTRIBUTION_HASH]
      end

      def record_page_view
        PageView.create(path: Path[request.path], visit_id: @visit_id, request_id: request.uuid)
      end

      def save
        session[:landable] = {
          VISIT_ID         => @visit_id,
          VISIT_TIME       => Time.current,
          VISITOR_ID       => @visitor_id,
          VISITOR_HASH     => visitor_hash,
          ATTRIBUTION_HASH => attribution? ? attribution_hash : @attribution_hash
        }
      end

      def identify(identifier)
        visit = Visit.find(@visit_id)
        visit.owner = identifier
        visit.save!

        Ownership.where(cookie_id: @cookie_id, owner_id: visit.owner_id).first_or_create
      end
    end
  end
end
