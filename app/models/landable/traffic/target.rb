module Landable
  module Traffic
    class Target < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :target, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
