class AddDeletedAtToThemes < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.themes", :deleted_at, :timestamp
  end
end
