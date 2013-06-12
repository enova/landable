module Landable
  class AccessToken < ActiveRecord::Base
    self.table_name = 'landable.access_tokens'

    belongs_to :author
    validates_presence_of :author_id
    validates_presence_of :expires_at

    before_validation do |token|
      token.expires_at ||= 8.hours.from_now
    end

    scope :fresh,   -> { where('expires_at > ?',  Time.zone.now) }
    scope :expired, -> { where('expires_at <= ?', Time.zone.now) }

    def self.generate_for_author(author)
      create!(author: author)
    end

    def refresh!
      update_column :expires_at, 8.hours.from_now
    end

    def fresh?
      expires_at && expires_at > Time.zone.now
    end

    def expired?
      !fresh?
    end
  end
end
