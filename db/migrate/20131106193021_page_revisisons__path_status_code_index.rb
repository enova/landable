class PageRevisisonsPathStatusCodeIndex < Landable::Migration
  def up
    execute <<-SQL
      DROP INDEX #{Landable.configuration.database_schema_prefix}landable.#{Landable.configuration.database_schema_prefix}landable_page_revisions__path;
      CREATE INDEX #{Landable.configuration.database_schema_prefix}landable_page_revisions__path_status_code
              ON #{Landable.configuration.database_schema_prefix}landable.page_revisions(path, status_code);
    SQL
  end
end
