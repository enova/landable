module Landable
  class Audit < ActiveRecord::Base
    include Landable::TableName

    validates :approver, presence: true

    belongs_to :auditable, polymorphic: true
  end
end
