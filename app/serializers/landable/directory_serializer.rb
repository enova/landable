module Landable
  class DirectorySerializer < ActiveModel::Serializer
    attributes :path
    has_many   :directories, serializer: DirectorySerializer
    has_many   :pages, serializer: PageSerializer
  end
end
