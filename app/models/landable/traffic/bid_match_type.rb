module Landable
  module Traffic
    class BidMatchType < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :bid_match_type, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
