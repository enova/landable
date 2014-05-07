class AddIndexOnPageRevisionsPath < Landable::Migration
  def up
    execute "CREATE INDEX #{Landable.configuration.database_schema_prefix}landable_page_revisions__path 
              ON #{Landable.configuration.database_schema_prefix}landable.page_revisions(path)"
  end
end
