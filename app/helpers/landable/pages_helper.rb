module Landable
  module PagesHelper
    def landable(page = current_page)
      return Landable::NullPageDecorator.new if page.nil?
      @landable ||= Landable::PageDecorator.new(page)
    end

    def current_page
      if Page.exists?(params[:id])
        current_page = Page.find(params[:id])
      elsif PageRevision.exists?(params[:id])
        current_page = PageRevision.find(params[:id])
      else
        current_page = Page.by_path(request.path)
      end

      @current_page ||= current_page
    end
  end
end
