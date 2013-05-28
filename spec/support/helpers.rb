module Landable
  module Spec
    module CoreHelpers
      def random_uuid
        SecureRandom.uuid
      end
    end

    module HttpHelpers
      def encode_basic_auth(username, token)
        ActionController::HttpAuthentication::Basic.encode_credentials(username, token)
      end
    end
  end
end
