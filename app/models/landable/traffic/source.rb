module Landable
  module Traffic
    class Source < ActiveRecord::Base
      include Landable::Traffic::TableName

      lookup_by :source, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
