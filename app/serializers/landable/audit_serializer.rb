module Landable
  class AuditSerializer < ActiveModel::Serializer
    attributes :id, :flags, :notes, :approver
    attributes :auditable_type, :auditable_id, :created_at

    def auditable_type
      if object.auditable_type == 'Landable::Page'
        object.auditable_type = 'page'
      else
        object.auditable_type = 'template'
      end
    end
  end
end
