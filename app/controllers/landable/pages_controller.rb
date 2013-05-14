require_dependency "landable/application_controller"

module Landable
  class PagesController < ApplicationController
    def index
      @pages = Page.all
      render json: @pages
    end

    def create
      @page = Page.new params[:page]
      @page.save!
      render json: @page, status: :created, location: url_for(@page)
    end

    def show
      @page = Page.find! params[:id]
      render json: @page
    end
  end
end
