module Landable
  module Traffic
    class Creative < ActiveRecord::Base
      include Landable::TableName

      lookup_by :creative, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
