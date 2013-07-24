require_dependency "landable/search_engine"
require_dependency "landable/asset"

module Landable
  class ScreenshotSearchEngine < SearchEngine
    def initialize(filters)
      super Screenshot.all, filters, order: 'updated_at DESC'
    end

    def filter_by!(filters)
      if ids = as_array(filters[:ids])
        @scope = @scope.where(screenshot_id: ids)
      end

      screenshotable =
        begin
          if page_id = filters[:page_id].presence
            Landable::Page.find(page_id)
          elsif page_revision_id = filters[:page_revision_id].presence
            Landable::PageRevision.find(page_revision_id)
          end
        end

      if screenshotable
        @scope = @scope.where(screenshotable: screenshotable)
      end
    end
  end
end
