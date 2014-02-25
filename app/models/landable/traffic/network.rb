module Landable
  module Traffic
    class Network < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :network, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
