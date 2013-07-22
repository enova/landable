module Landable
  class StatusCodeSerializer < ActiveModel::Serializer
    attributes :id, :code, :description, :is_redirect, :is_missing
  end
end
