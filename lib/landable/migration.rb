class Landable::Migration < ActiveRecord::Migration
  class << self
    def connection_search_path(conn)
      conn.execute("SHOW SEARCH_PATH")[0]["search_path"]
    end

    def models
      @models ||= begin
        c = Landable.constants.map { |c| "Landable::#{c.to_s}".constantize }
        c += Landable::Traffic.constants.map { |c| "Landable::Traffic::#{c.to_s}".constantize }
        c.select { |c| c.kind_of? Class and c.ancestors.include? ActiveRecord::Base }
      end
    end

    def clear_cache!
      models.each &:reset_primary_key
      ActiveRecord::Base.connection.schema_cache.clear!
    end
  end

  def exec_migration(conn, direction)
    original_search_path = self.class.connection_search_path conn
    super
    conn.schema_search_path = original_search_path

    # reset a few things, lest we pollute the way for those who follow
    self.class.clear_cache!
  end

end
