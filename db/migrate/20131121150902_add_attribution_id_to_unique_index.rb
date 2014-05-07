class AddAttributionIdToUniqueIndex < Landable::Migration
  def up
    execute <<-SQL
      ALTER TABLE #{Landable.configuration.database_schema_prefix}landable_traffic.referers 
              DROP CONSTRAINT referers_domain_id_path_id_query_string_id_key;
      CREATE UNIQUE INDEX referers_domain_id_path_id_query_string_id_attribution_id 
              ON #{Landable.configuration.database_schema_prefix}landable_traffic.referers(domain_id, path_id, query_string_id, attribution_id);
    SQL
  end
end
