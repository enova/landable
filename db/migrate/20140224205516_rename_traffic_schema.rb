class RenameTrafficSchema < Landable::Migration
  def traffic_schema
    "#{Landable.configuration.database_schema_prefix}landable_traffic"
  end

  def schema_exists(schema)
    execute("SELECT COUNT(*) FROM pg_namespace WHERE nspname = '#{schema}'")[0]['count'] == '1'
  end

  def move_objects(from_schema, to_schema, relkind, object_type)
    # move objects from public to new schema
    objects = select_all("
      SELECT o.relname
        FROM pg_class o
        JOIN pg_namespace n
        ON n.oid=o.relnamespace
        AND n.nspname = '#{from_schema}'
        AND o.relkind = '#{relkind}'
        ORDER BY o.relname
    ")

    objects.each do |object|
      sql = %(
        ALTER #{object_type} #{from_schema}.#{object['relname']}
          SET SCHEMA #{to_schema}
            )
      puts "Moving #{from_schema}.#{object['relname']} TO #{to_schema}"
      execute sql
    end
  end

  def up
    return unless schema_exists('traffic')
    execute("CREATE SCHEMA #{traffic_schema}")
    move_objects('traffic', "#{traffic_schema}", 'r', 'TABLE')
    move_objects('traffic', "#{traffic_schema}", 'S', 'SEQUENCE')
  end
end
