module Landable
  module Traffic
    class Placement < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :placement, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
