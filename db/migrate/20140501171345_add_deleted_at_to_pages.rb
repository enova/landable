class AddDeletedAtToPages < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.pages", :deleted_at, :timestamp
  end
end
