module Landable
  module Api
    class AccessTokensController < ApiController
      skip_before_filter :require_author!, only: [:create, :show]

      def create
        if entry = LdapAuthenticationService.call(params[:username], params[:password])
          author = AuthorRegistrationService.call(entry)
          render json: AccessToken.create!(author: author), status: :created,
            serializer: AccessTokenSerializer
        else
          head :unauthorized
        end
      end

      def show
        render json: AccessToken.find(params[:id]), serializer: AccessTokenSerializer
      end

      def destroy
        AccessToken.find(params[:id]).destroy!
        head :no_content
      end
    end
  end
end
