module Landable
  class SearchEngine
    def initialize(base_scope, filters, options = {})
      @scope = base_scope
      filter_by!(filters)
    end

    def results
      @scope
    end

    def meta
      { search: { total_results: @scope.count } }
    end

    def filter_by!(filters)
      raise NotImplementedError
    end

    protected

    def as_array(value)
      array = Array(value)
      array if array.any?
    end
  end
end
