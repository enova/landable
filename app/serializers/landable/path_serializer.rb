module Landable
  class PathSerializer < ActiveModel::Serializer
    attributes :path, :status_code

    # Delegated from Page; TODO rm all of this once they are merged.
    attribute :page_id, key: :id
    attributes :title, :body

    has_one :theme, embed: :object
  end
end
