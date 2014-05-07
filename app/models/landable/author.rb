module Landable
  class Author < ActiveRecord::Base
    include Landable::TableName
    has_many :access_tokens

    def self.authenticate!(username, token_id)
      return unless author = where(username: username).first
      return unless author.access_tokens.fresh.exists?(token_id)
      author
    end
  end
end
