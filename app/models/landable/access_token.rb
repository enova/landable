module Landable
  class AccessToken < ActiveRecord::Base
    include Landable::TableName

    belongs_to :author
    validates_presence_of :author_id
    validates_presence_of :expires_at

    before_validation do |token|
      token.expires_at ||= 8.hours.from_now
    end

    scope :fresh,   -> { where('expires_at > ?',  Time.zone.now) }
    scope :expired, -> { where('expires_at <= ?', Time.zone.now) }

    def refresh!
      update_column :expires_at, 8.hours.from_now
    end
  end
end
