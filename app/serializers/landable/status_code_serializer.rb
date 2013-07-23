module Landable
  class StatusCodeSerializer < ActiveModel::Serializer
    attributes :id, :code, :description, :is_redirect, :is_missing, :is_okay

    def is_redirect
      object.is_redirect?
    end

    def is_missing
      object.is_missing?
    end

    def is_okay
      object.is_okay?
    end
  end
end
