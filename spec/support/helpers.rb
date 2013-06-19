module Landable
  module Spec
    module CoreHelpers
      def random_uuid
        SecureRandom.uuid
      end

      def at_json(path, object = last_json)
        path.split('/').reduce object do |parent, key|
          key = key.to_i if Array === parent
          parent.fetch key
        end
      end
    end

    module HttpHelpers
      def encode_basic_auth(username, token)
        ActionController::HttpAuthentication::Basic.encode_credentials(username, token)
      end
    end
  end
end
