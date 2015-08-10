module Landable
  class AccessTokenSerializer < ActiveModel::Serializer
    attributes :id, :expires_at, :permissions
    has_one :author, embed: :object
  end
end
