module Landable
  class AuditSerializer < ActiveModel::Serializer
    attributes :id, :flags, :notes, :approver
    has_one    :auditable
  end
end
