module Landable
  module ApplicationHelper
    def method_missing(method, *args, &block)
      return main_app.send(method, *args) if method =~ /_(path|url)$/ && main_app.respond_to?(method)
      super
    end

    def respond_to?(method)
      return true if method =~ /_(path|url)$/ && main_app.respond_to?(method)
      super
    end
  end
end
