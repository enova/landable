module Landable
  class AuthorSerializer < ActiveModel::Serializer
    attributes :id, :username, :email, :first_name, :last_name, :can_read, :can_edit, :can_publish
  end
end
