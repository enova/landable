module Landable
  module Tracking
    class Cookie < ActiveRecord::Base
      self.table_name = 'traffic.cookies'

      has_many :ownerships
      has_many :visits

      after_initialize do
        self.id ||= SecureRandom.uuid
      end
    end
  end
end
