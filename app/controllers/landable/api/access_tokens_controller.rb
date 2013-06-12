require_dependency "landable/api_controller"

module Landable
  module Api
    class AccessTokensController < ApiController
      skip_before_filter :require_author!, only: [:create]

      def create
        ident  = AuthenticationService.call(params[:username], params[:password])
        author = RegistrationService.call(ident)
        respond_with AccessToken.create!(author: author), status: :created
      rescue Landable::AuthenticationFailedError
        head :unauthorized
      end

      def update
        token = find_own_access_token params[:id]
        token.refresh!
        respond_with token
      end

      def destroy
        token = find_own_access_token params[:id]
        token.destroy!
        head :no_content

      rescue ActiveRecord::RecordNotFound
        head :unauthorized
      end

      private

      def find_own_access_token(id = params[:id])
        AccessToken.where(author_id: current_author.id).find(id)
      end
    end
  end
end
