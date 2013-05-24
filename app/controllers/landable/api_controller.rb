module Landable
  class ApiController < ApplicationController
    before_filter :require_author!

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
