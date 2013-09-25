require 'rails/generators'

module Landable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../../templates", __FILE__)

      desc 'Creates the Landable initializer'

      def copy_initializer
        template 'landable.rb', 'config/initializers/landable.rb'
      end
    end
  end
end
