module Landable
  class AuditSerializer < ActiveModel::Serializer
    attributes :id, :flags, :notes, :approver
    attributes :auditable_type, :auditable_id

    def auditable_type
      object.auditable_type == 'Landable::Page' ? 'Page' : 'Template'
    end
  end
end
