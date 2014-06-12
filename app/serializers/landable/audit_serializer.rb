module Landable
  class AuditSerializer < ActiveModel::Serializer
    attributes :id, :flags, :notes, :approver
    attributes :auditable_type, :auditable_id, :created_at

    def auditable_type
      if object.auditable_type.present?
        object.auditable_type.underscore.gsub(/^landable\//, '')
      end
    end
  end
end
