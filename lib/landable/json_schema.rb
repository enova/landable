module Landable
  module JsonSchema
    ValidationError = Class.new(StandardError)
    extend self

    def validate(schema, json)
      require 'json-schema'
      initialize_validator!
      json = JSON.parse(json) if String === json
      JSON::Validator.fully_validate(schema, json, validate_schema: true)

    rescue LoadError
      []
    end

    def validate!(schema, json)
      errors = validate(schema, json)
      raise ValidationError.new({ json: json, errors: errors }.inspect) if errors.any?
    end

    def schema_uri(type)
      return unless path = schema_path(type)
      "file://#{path}#"
    end

    def schema_path(type)
      path = Landable::Engine.root.join('doc', 'schema', "#{type}.json")
      File.expand_path(path.to_s) if path.exist?
    end

    private

    def initialize_validator!
      return if @validator_intitialized
      JSON::Validator.cache_schemas = true
      @validator_initialized = true
    end
  end
end
