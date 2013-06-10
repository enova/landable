module Landable
  class ApiResponder < ActionController::Responder
    module NamespacedSerializers
      def to_format
        case resource
        when Array
          declare_serializer!(:each_serializer, resource.first.class)
        when ActiveRecord::Relation
          declare_serializer!(:each_serializer, resource.klass)
        else
          declare_serializer!(:serializer, resource.class)
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

      def declare_serializer!(key, klass)
        serializer = "#{klass}Serializer".constantize
        options[key] = serializer
        controller.response.headers['X-Serializer'] = serializer.name if Rails.env.development?
      rescue NameError
      end
    end

    include NamespacedSerializers
  end
end
