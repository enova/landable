module Landable
  module Traffic
    class Content < ActiveRecord::Base
      self.table_name = 'traffic.contents'

      lookup_by :content, cache: 50, find_or_create: true

      has_many :attributions
    end
  end
end
