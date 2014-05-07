require 'landable'
require 'rails/generators'

module Landable
  module Generators
    class Base < ::Rails::Generators::NamedBase
      class << self
        def namespace
          "landable:#{generator_name}"
        end

        def source_root
          @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), "landable", generator_name, "templates"))
        end

        def target_root
          File.expand_path(Rails.root.join("app", "assets"))
        end
      end
    end
  end
end
