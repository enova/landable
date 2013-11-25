module Landable
  module PagesHelper
    def landable(page = current_page)
      return Landable::NullPageDecorator.new if page.nil?
      @landable ||= Landable::PageDecorator.new(page)
    end

    def current_page
      current_page = Page.exists?(params[:id]) ? Page.find(params[:id]) : Page.by_path(request.path)

      @current_page ||= current_page
    end
  end
end
