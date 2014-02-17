module Landable
  module Traffic
    class Cookie < ActiveRecord::Base
      self.table_name = "#{Landable.configuration.schema_prefix}landable_traffic.cookies"

      lookup_by :cookie_id, cache: 100, find: true

      has_many :ownerships
      has_many :visits

      after_initialize do
        self.id ||= SecureRandom.uuid
      end
    end
  end
end
