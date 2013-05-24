module Landable
  class AccessTokenSerializer < ActiveModel::Serializer
    attributes :id, :expires_at
    has_one :author, embed: :object
  end
end
