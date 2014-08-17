module Landable
  module Traffic
    class Content < ActiveRecord::Base
      include Landable::TableName

      lookup_by :content, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
