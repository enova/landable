module Landable
  class PageRevisionSerializer < ActiveModel::Serializer
    attributes :id, :ordinal
    attributes :snapshot_attributes
    attributes :created_at

    has_one :page, embed: :id
    has_one :theme, embed: :id
    has_one :author, embed: :id

    def theme_id
      object.snapshot_attributes[:theme_id]
    end

    def theme
      Theme.find(theme_id) if theme_id
    end
  end
end
