module Landable
  class DirectorySerializer < ActiveModel::Serializer
    attributes :path
    has_many   :directories
    has_many   :pages
  end
end
