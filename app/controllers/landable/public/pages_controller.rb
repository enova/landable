module Landable
  module Public
    class PagesController < ApplicationController
      def show
        @page = Page.first
        render text: "<html><body><p>XSS or bust:</p><p>#{@page.body}</p></body></html>", layout: nil
      end
    end
  end
end
