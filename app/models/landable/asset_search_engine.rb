require_dependency "landable/search_engine"
require_dependency "landable/asset"

module Landable
  class AssetSearchEngine < SearchEngine
    def initialize(filters)
      super Asset.all, filters
    end

    def filter_by!(filters)
      if ids = as_array(filters[:ids])
        @scope = @scope.where(asset_id: ids)
      end

      if name = filters[:name].presence
        @scope = @scope.where('LOWER(name) LIKE ?', "%#{name}%".downcase)
      end
    end
  end
end
