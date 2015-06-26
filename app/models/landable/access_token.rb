module Landable
  class AccessToken < ActiveRecord::Base
    include Landable::TableName

    # Maximum Token age, in hours.
    MAX_AGE = Landable::configuration['ldap'][:access_token_max_age]

    belongs_to :author
    validates_presence_of :author_id
    validates_presence_of :expires_at
    validates_presence_of :permissions

    before_validation do |token|
      token.expires_at ||= MAX_AGE.hours.from_now
    end

    scope :fresh,   -> { where('expires_at > ?',  Time.zone.now) }
    scope :expired, -> { where('expires_at <= ?', Time.zone.now) }

    def refresh!
      update_column :expires_at, MAX_AGE.hours.from_now
    end

    def can_publish?
      permissions.include?('publish')
    end

    def can_edit?
      permissions.include?('edit')
    end

    def can_read?
      permissions.include?('read')
    end
  end
end
