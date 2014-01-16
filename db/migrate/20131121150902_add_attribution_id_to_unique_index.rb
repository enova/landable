class AddAttributionIdToUniqueIndex < Landable::Migration
  def up
    execute "ALTER TABLE traffic.referers DROP CONSTRAINT referers_domain_id_path_id_query_string_id_key"
    execute "CREATE UNIQUE INDEX referers_domain_id_path_id_query_string_id_attribution_id ON traffic.referers(domain_id, path_id, query_string_id, attribution_id)"
  end
end
