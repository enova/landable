module Landable
  module Traffic
    class Position < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :position, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
