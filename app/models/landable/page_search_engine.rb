require_dependency 'landable/search_engine'
require_dependency 'landable/page'

module Landable
  class PageSearchEngine < SearchEngine
    def initialize(filters, options = {})
      super Page.all, filters, options
    end

    def filter_by!(filters)
      if ids = as_array(filters[:ids])
        @scope = @scope.where(page_id: ids)
      end

      if path = filters[:path].presence
        @scope = @scope.with_fuzzy_path(path)
      end
    end
  end
end
