class DropBrowserScreenshotTables < ActiveRecord::Migration
  def up
    drop_table    "#{Landable.configuration.database_schema_prefix}landable.screenshots"
    drop_table    "#{Landable.configuration.database_schema_prefix}landable.browsers"
  end
end