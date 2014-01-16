class Landable::Migration < ActiveRecord::Migration
  class << self
    def connection_search_path(conn)
      conn.execute("SHOW SEARCH_PATH")[0]["search_path"]
    end
  end

  def exec_migration(conn, direction)
    original = self.class.connection_search_path conn
    super
    conn.schema_search_path = original
  end

end
