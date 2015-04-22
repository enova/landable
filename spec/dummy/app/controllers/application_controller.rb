class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # This is an un-pretty version of what apps using Landable should be doing.
  rescue_from Landable::Error do |error|
    render status: error.status_code, text: error.message
  end

end
