module Landable
  module Api
    class AccessTokensController < ApiController
      skip_before_filter :require_author!, only: [:create]

      Deject self
      dependency(:ldap_service) do
        LdapAuthenticationService.new(params[:username], params[:password])
      end

      def create
        entry  = ldap_service.authenticate!
        author = AuthorRegistrationService.call(entry)
        render json: AccessToken.create!(author: author), status: :created,
            serializer: AccessTokenSerializer
      rescue LdapAuthenticationService::LdapAuthenticationError
        head :unauthorized
      end

      def destroy
        AccessToken.find(params[:id]).destroy!
        head :no_content
      end
    end
  end
end
