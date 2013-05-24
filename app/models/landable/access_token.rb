module Landable
  class AccessToken < ActiveRecord::Base
    self.table_name = 'landable.access_tokens'

    belongs_to :author
    validates_presence_of :author_id
    validates_presence_of :expires_at

    before_validation do |token|
      token.expires_at ||= 2.hours.from_now
    end

    scope :unexpired, -> { where('expires_at > ?', Time.now) }

    def self.generate_for_author(author)
      create!(author: author)
    end

    def expired?
      expires_at > Time.now
    end
  end
end
