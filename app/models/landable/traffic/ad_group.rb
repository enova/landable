module Landable
  module Traffic
    class AdGroup < ActiveRecord::Base
      include Landable::TableName

      lookup_by :ad_group, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
