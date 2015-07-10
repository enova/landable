module Landable
  class AccessToken < ActiveRecord::Base
    include Landable::TableName

    # Maximum token age, in hours
    MAX_AGE = (Landable.configuration['ldap'][:access_token_max_age] || 8).hours

    belongs_to :author
    validates_presence_of :author_id
    validates_presence_of :expires_at
    validates_presence_of :permissions

    before_validation do |token|
      token.expires_at ||= expiration
    end

    scope :fresh,   -> { where('expires_at > ?',  Time.zone.now) }
    scope :expired, -> { where('expires_at <= ?', Time.zone.now) }

    def refresh!
      update_column :expires_at, expiration
    end

    def can_read?
      permissions['read'] == 'true'
    end

    def can_edit?
      permissions['edit'] == 'true'
    end

    def can_publish?
      permissions['publish'] == 'true'
    end

    private

    def expiration
      MAX_AGE.from_now
    end
  end
end
