module Landable
  class Theme
    include ActiveModel::SerializerSupport

    attr_reader :name, :description, :screenshot_urls

    def initialize(name, description, screenshot_urls)
      @name = name
      @description = description
      @screenshot_urls = screenshot_urls
    end
  end
end
