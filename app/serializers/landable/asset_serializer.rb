module Landable
  class AssetSerializer < ActiveModel::Serializer
    attributes :id, :name, :description
    attributes :file_size, :mime_type, :md5sum
    attributes :created_at, :updated_at
    attributes :public_url

    embed :ids

    has_one  :author
    has_many :pages
    has_many :themes

    def public_url
      'http://no.idea.how/TODO/this'
    end
  end
end
