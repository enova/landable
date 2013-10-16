require_dependency "landable/application_controller"
require_dependency "landable/api_responder"
require_dependency "landable/author"

module Landable
  class ApiController < ApplicationController
    # skip any of these that may have been inherited from ::ApplicationController
    skip_before_filter :protect_from_forgery
    skip_before_action :verify_authenticity_token

    before_filter :require_author!

    respond_to :json
    self.responder = Landable::ApiResponder

    rescue_from ActiveRecord::RecordNotFound do |ex|
      head 404
    end

    rescue_from ActiveRecord::RecordInvalid do |ex|
      render json: { errors: ex.record.errors }, status: :unprocessable_entity
    end

    rescue_from ActionController::UnknownFormat do |ex|
      head :not_acceptable
    end

    rescue_from ActiveRecord::StaleObjectError do |ex|
      render json: { author: ex.record.updated_by_author }, status: 409
    end

    rescue_from PG::Error do |ex|
      if ex.message =~ /invalid input syntax for uuid/
        head :not_found
      else
        raise ex
      end
    end


    # here's looking at you, http://developer.github.com/v3/media/
    # mime type matching is still handled by rails - see lib/landable/mime_types.rb

    API_MEDIA_REGEX = /^application\/vnd\.landable(\.v(?<version>[\w\-]+))?(\.(?<param>(?:[\w\-]+)))?(\+(?<format>[\w\-]+))?/

    def api_media
      @api_media ||= begin
        accept = request.headers['Accept'].match(API_MEDIA_REGEX) || {}

        {
          version: accept['version'].presence.try(:to_i) || Landable::API_VERSION,
          format:  accept['format'].presence.try(:to_sym) || :json,
          param:   accept['param'].presence,
        }
      end
    end

    protected

    def require_author!
      head :unauthorized if current_author.nil?
    end

    def current_author
      return @current_author if @current_author
      authenticate_with_http_basic do |username, token|
        @current_author = Author.authenticate!(username, token)
      end
    end

  end
end
