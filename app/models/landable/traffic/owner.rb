module Landable
  module Traffic
    class Owner < ActiveRecord::Base
      include Landable::Traffic::TableName

      has_many :ownerships
      has_many :visits
    end
  end
end
