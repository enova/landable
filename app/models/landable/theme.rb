module Landable
  class Theme
    include ActiveModel::SerializerSupport

    attr_reader :name, :description, :layout, :screenshot_urls

    def initialize(attributes)
      attributes.each do |attr, value|
        instance_variable_set(:"@#{attr}", value)
      end
    end
  end
end
