module Landable
  class AuditSerializer < ActiveModel::Serializer
    attributes :id, :flags, :notes, :approver
    attributes :auditable_type, :auditable_id, :created_at

    def auditable_type
      object.auditable_type == 'Landable::Page' ? 'page' : 'template'
    end
  end
end
