require_dependency "landable/application_controller"
require_dependency "landable/api_responder"
require_dependency "landable/author"

module Landable
  class ApiController < ApplicationController
    skip_before_filter :protect_from_forgery
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
