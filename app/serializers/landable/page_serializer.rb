module Landable
  class PageSerializer < ActiveModel::Serializer
    attributes :id
    attributes :path
    attributes :title
    attributes :body
    attributes :head_tag
    attributes :redirect_url
    attributes :meta_tags
    attributes :is_publishable
    attributes :preview_path
    attributes :lock_version

    embed    :ids
    has_one  :theme
    has_one  :published_revision
    has_one  :category
    has_one  :status_code
    has_one  :updated_by_author, root: :authors, include: true, serializer: AuthorSerializer

    def category
      object.category || Landable::Category.where(name: 'Uncategorized').first
    end

    def meta_tags
      object.meta_tags || {}
    end

    def status_code
      object.status_code
    end
  end
end
