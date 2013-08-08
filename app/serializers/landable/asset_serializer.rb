module Landable
  class AssetSerializer < ActiveModel::Serializer
    attributes :id, :name, :description
    attributes :file_size, :mime_type, :md5sum
    attributes :created_at, :updated_at
    attributes :public_url

    embed :ids

    has_one  :author, embed_key: :username, include: true, serializer: AuthorSerializer
  end
end
