module Landable
  class SearchEngine
    def initialize(base_scope, filters, options = {})
      @scope = base_scope
      @limit = options[:limit].to_i or 50
      filter_by!(filters)
    end

    def results
      @scope.limit @limit
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
