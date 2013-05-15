module Landable
  # having trouble getting this to load properly from Landable::Api; leaving it here for now.
  class PageSerializer < ActiveModel::Serializer
    attributes :id, :title, :body
  end
end