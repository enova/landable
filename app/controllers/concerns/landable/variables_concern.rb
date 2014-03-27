require 'active_support/concern'

module Landable
  module VariablesConcern
    # includes
    extend ActiveSupport::Concern
    
    included do
      # attribute definitions
      cattr_accessor :imported_variables do
        {}
      end
    end
    
    # standard methods
    
    # custom methods
    module ClassMethods
      def register_landable_variable(variable_name, method_name = nil)
        method_name ||= variable_name
        
        imported_variables[variable_name] = method_name
      end
    end
    
    def fetch_landable_variables
      variables = {}
      
      imported_variables.each do |variable_name, method_name| 
        variables[variable_name] = send(method_name)
      end

      variables.with_indifferent_access
    end
    
    # end
  end
end