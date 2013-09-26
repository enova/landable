require 'rails/generators'

module Landable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../../templates', __FILE__)

      desc 'Creates the Landable initializer and installs the engine route'

      def copy_initializer
        template 'landable.rb', 'config/initializers/landable.rb'
      end

      def add_landable_route
        route 'mount Landable::Engine => \'/\' # move this to the end of your routes block'
      end
    end
  end
end
