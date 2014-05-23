module Landable
  class PageSerializer < ActiveModel::Serializer

    attributes :abstract, :body, :deleted_at, :head_content, :hero_asset_name, 
               :id, :is_publishable, :lock_version, :meta_tags, :path, 
               :preview_path, :redirect_url, :status_code, :title

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
