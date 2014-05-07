module Landable
  module TableName
    extend ActiveSupport::Concern 

    included do
      model_name = self.model_name.element.pluralize
      schema_name = "#{Landable.configuration.database_schema_prefix}landable"
      self.table_name = "#{schema_name}.#{model_name}"
    end

  end
end