module Landable
  class ApiResponder < ActionController::Responder
    def to_format
      if serializer = resource_serializer
        options[collection_resource? ? :each_serializer : :serializer] = serializer
        controller.response.headers['X-Serializer'] = serializer.name if leaky?
      end

      if leaky? && format == :json && schema = json_schema
        key  = collection_resource? ? resource_name.pluralize : resource_name
        link = "<#{schema}>; rel=\"describedby\"; anchor=\"#/#{key}\""
        link = "#{link}; collection=\"collection\"" if collection_resource?
        controller.response.headers['Link'] = link
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

    def collection_resource?
      Array === resource || ActiveRecord::Relation === resource
    end

    def json_schema
      path = Landable::Engine.root.join('doc', 'schema', "#{resource_name}.json")
      return unless path.exist?
      "file://#{path}#"
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
  end
end
