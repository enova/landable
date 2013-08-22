module Landable
  class HeadTagSerializer < ActiveModel::Serializer
    attributes :id, :content
    embed :ids
    has_one :page
  end
end
