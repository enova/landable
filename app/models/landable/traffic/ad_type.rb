module Landable
  module Traffic
    class AdType < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :ad_type, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
