require_dependency "landable/api_controller"

module Landable
  module Api
    class AccessTokensController < ApiController
      skip_before_filter :require_author!, only: [:create]

      def create
        ident  = AuthenticationService.call(params[:username], params[:password])
        author = RegistrationService.call(ident)

        render json: AccessToken.create!(author: author), status: :created,
          serializer: AccessTokenSerializer

      rescue Landable::AuthenticationFailedError
        head :unauthorized
      end

      def destroy
        AccessToken.find(params[:id]).destroy!
        head :no_content
      end
    end
  end
end
