module Landable
  module ApiSpecHelper
    def use_access_token(author = nil, token = nil)
      author ||= create :author
      token  ||= create :access_token, author: author
      request.env['HTTP_AUTHORIZATION'] = encode_basic_auth(author.username, token.id)
      token
    end

    def do_not_use_access_token
      request.env.delete 'HTTP_AUTHORIZATION'
    end

    def encode_basic_auth(username, token)
      ActionController::HttpAuthentication::Basic.encode_credentials(username, token)
    end
  end
end
