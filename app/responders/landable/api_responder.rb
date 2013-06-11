require_dependency "landable/json_schema"

module Landable
  class ApiResponder < ActionController::Responder
    def to_json
      json = to_format

      if validate_schema? && schema = response_schema
        Landable::JsonSchema.validate!(schema, json.first)
      end

      json
    end

    def to_format
      if serializer = resource_serializer
        options[collection_resource? ? :each_serializer : :serializer] = serializer
        controller.response.headers['X-Serializer'] = serializer.name if Rails.env.development?
      end

      # For updates, rails defaults to returning 204 No Content;
      # we would actually prefer that the updated record be returned,
      # in case an update to one key necessitates an automatic update to another.
      if patch? || put?
        display resource
      else
        super
      end
    end

    private

    def leaky?
      Rails.env.development? || Rails.env.test?
    end

    def validate_schema?
      Rails.env.development? || Rails.env.test?
    end

    def collection_resource?
      Array === resource || ActiveRecord::Relation === resource
    end

    def resource_name
      @resource_name ||= resource_class.name.demodulize.underscore
    end

    def resource_class
      @resource_class ||=
        case resource
        when Array then resource.first.class
        when ActiveRecord::Relation then resource.klass
        else resource.class
        end
    end

    def resource_serializer
      return if @resource_serializer == false
      @resource_serializer ||= "#{resource_class}Serializer".constantize
    rescue NameError
      @resource_serializer = false
      nil
    end

    def response_schema
      return unless uri = Landable::JsonSchema.schema_uri(resource_name)

      if collection_resource?
        collection_of(resource_name.pluralize, uri)
      else
        instance_of(resource_name, uri)
      end
    end

    def instance_of(type, uri)
      { 'title' => type,
        'properties' => {
          type => {
            '$ref' => uri.to_s,
            'required' => true
          }
        }
      }
    end

    def collection_of(type, uri)
      { 'title' => "Collection of #{type}",
        'properties' => {
          type => {
            'type' => 'array',
            'items' => [{ '$ref' => uri.to_s }]
          }
        }
      }
    end
  end
end
