class AddDeletedAtToAssets < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.assets", :deleted_at, :timestamp
  end
end
