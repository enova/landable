module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :path, :title, :body
    attributes :head_content, :redirect_url
    attributes :meta_tags, :is_publishable
    attributes :preview_path, :lock_version
    attributes :status_code, :abstract
    attributes :hero_asset_name, :audit_flags
    attributes :deleted_at

    embed    :ids
    has_one  :theme
    has_one  :published_revision
    has_one  :category
    has_one  :updated_by_author, root: :authors, include: true, serializer: AuthorSerializer

    def category
      object.category || Landable::Category.where(name: 'Uncategorized').first
    end

    def meta_tags
      object.meta_tags || {}
    end
  end
end
