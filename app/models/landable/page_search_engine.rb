require_dependency 'landable/search_engine'
require_dependency 'landable/page'

module Landable
  class PageSearchEngine < SearchEngine
    def initialize(filters, options = {})
      super Page.all, filters, options
    end

    def filter_by!(filters)
      ids = as_array(filters[:ids])
      @scope = @scope.where(page_id: ids) if ids

      path = filters[:path].presence
      return unless path
      @scope = @scope.with_fuzzy_path(path)
    end
  end
end
