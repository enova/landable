module Landable
  class Author < ActiveRecord::Base
    include Landable::TableName
    has_many :access_tokens

    def self.authenticate!(username, token_id)
      author = where(username: username).first
      return unless author && author.access_tokens.fresh.exists?(token_id)
      author
    end

    def can_read
      token = access_tokens.fresh.last
      token.present? && token.can_read?
    end

    def can_edit
      token = access_tokens.fresh.last
      token.present? && token.can_edit?
    end

    def can_publish
      token = access_tokens.fresh.last
      token.present? && token.can_publish?
    end
  end
end
