module Landable
  class SearchEngine
    def initialize(base_scope, filters, options = {})
      @scope = base_scope

      order! options[:order]
      limit! options[:limit]

      filter_by!(filters)
    end

    def results
      @scope
    end

    def meta
      { search: { total_results: @scope.count(:all) } }
    end

    def filter_by!(filters)
      raise NotImplementedError
    end

    def order!(order)
      @scope = @scope.order(order) if order
    end

    def limit!(limit)
      @scope = @scope.limit(limit) if limit
    end

    protected

    def as_array(value)
      array = Array(value)
      array if array.any?
    end
  end
end
