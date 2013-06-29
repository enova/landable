module Landable
  class PageSearchEngine
    def initialize(filters)
      @scope = Page.all
      @limit = 50
      filter_by!(filters)
    end

    def results
      @scope.limit(@limit)
    end

    def meta
      { total_results: @scope.count }
    end

    def filter_by!(filters)
      if ids = array_of(filters[:ids])
        @scope = @scope.where(page_id: ids)
      end

      if path = filters[:path].presence
        @scope = @scope.with_fuzzy_path(path)
      end
    end

    protected

    def array_of(value)
      array = Array(value)
      array if array.any?
    end
  end
end
