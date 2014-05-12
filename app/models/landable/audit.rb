module Landable
  class Audit < ActiveRecord::Base
    include Landable::TableName

    belongs_to :auditable, polymorphic: true
  end
end
