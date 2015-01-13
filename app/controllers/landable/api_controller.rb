require_dependency "landable/application_controller"
require_dependency "landable/api_responder"
require_dependency "landable/author"

module Landable
  class ApiController < ApplicationController
    # skip any of these that may have been inherited from ::ApplicationController
    skip_before_filter :protect_from_forgery
    skip_before_action :verify_authenticity_token

    # tracking is not necessary for API calls
    skip_around_action :track_with_landable!

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
          version: Landable::VERSION::STRING,
          format:  request.format.symbol,
          param:   accept['param'].presence,
        }
      end
    end

    protected

    def require_author!
      head :unauthorized if current_author.nil?
    end

    def with_format(format, &block)
      old_formats = formats

      begin
        self.formats = [format]
        return block.call
      ensure
        self.formats = old_formats
      end
    end

    def generate_preview_for(page)
      if layout = page.theme.try(:file) || false
        content = with_format(:html) do
          render_to_string text: RenderService.call(page), layout: layout
        end
      else
        content = RenderService.call(page, preview: true)
      end
    end

    def current_author
      return @current_author if @current_author
      authenticate_with_http_basic do |username, token|
        @current_author = Author.authenticate!(username, token)
      end
    end

  end
end
