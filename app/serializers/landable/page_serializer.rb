module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id
    attributes :path, :title, :body
    attributes :head_content, :meta_tags
    attributes :status_code, :redirect_url
    attributes :is_publishable, :preview_path
    attributes :audit_flags
    attributes :hero_asset_name, :abstract
    attributes :lock_version
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
