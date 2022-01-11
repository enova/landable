module Landable
  module TableName
    extend ActiveSupport::Concern

    included do
      schema = "#{Landable.configuration.database_schema_prefix}landable"
      suffix = module_parent.name.demodulize.downcase

      schema += "_#{suffix}" unless suffix == 'landable'
      model_name = self.model_name.element.pluralize
      self.table_name = "#{schema}.#{model_name}"
    end
  end
end
