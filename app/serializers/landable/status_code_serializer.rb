module Landable
  class StatusCodeSerializer < ActiveModel::Serializer
    attributes :id, :code, :description
  end
end
