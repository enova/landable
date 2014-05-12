module Landable
  class AuditSerializer < ActiveModel::Serializer
    attributes :id, :flags, :notes, :approver
  end
end
