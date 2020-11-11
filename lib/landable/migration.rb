module Landable
  class Migration < ActiveRecord.version < Gem::Version.new("5.1") ? ActiveRecord::Migration : ActiveRecord::Migration[4.2]
    class << self
      def connection_search_path(conn)
        conn.execute('SHOW SEARCH_PATH')[0]['search_path']
      end

      def models
        @models ||= begin
                      classes = Landable.constants.map { |c| "Landable::#{c}".constantize }
                      classes += Landable::Traffic.constants.map { |c| "Landable::Traffic::#{c}".constantize }
                      classes.select { |c| c.is_a?(Class) && c.ancestors.include?(ActiveRecord::Base) }
                    end
      end

      def clear_cache!
        models.each(&:reset_primary_key)
        ActiveRecord::Base.connection.schema_cache.clear!
      end
    end

    def exec_migration(conn, direction)
      # come what may, keep the connection's schema search path intact
      with_clean_connection(conn) do
        super
      end

      # reset a few things, lest we pollute the way for those who follow
      self.class.clear_cache!
    end

    protected

    def with_clean_connection(conn)
      original_search_path = self.class.connection_search_path conn
      yield
      conn.schema_search_path = original_search_path
    end
  end
end
