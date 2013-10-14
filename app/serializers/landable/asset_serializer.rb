module Landable
  class AssetSerializer < ActiveModel::Serializer
    attributes :id, :name, :description
    attributes :file_size, :mime_type, :md5sum
    attributes :created_at, :updated_at
    attributes :public_url

    embed :ids

    has_one  :author, include: true, serializer: AuthorSerializer
    has_many :pages, include: true, serializer: PageSerializer
    has_many :themes, include: true, serializer: ThemeSerializer
  end
end
