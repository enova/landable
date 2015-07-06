module Landable
  class AccessToken < ActiveRecord::Base
    include Landable::TableName

    belongs_to :author
    validates_presence_of :author_id
    validates_presence_of :expires_at
    validates_presence_of :permissions

    before_validation do |token|
      token.expires_at ||= 8.hours.from_now
    end

    scope :fresh,   -> { where('expires_at > ?',  Time.zone.now) }
    scope :expired, -> { where('expires_at <= ?', Time.zone.now) }

    def refresh!
      update_column :expires_at, 8.hours.from_now
    end

    def can_publish?
      permissions['publish']
    end

    def can_edit?
      permissions['edit']
    end

    def can_read?
      permissions['read']
    end
  end
end
