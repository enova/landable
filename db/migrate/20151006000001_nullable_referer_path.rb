class NullableRefererPath < ActiveRecord::Migration
  def change
    schema_name = "#{Landable.configuration.database_schema_prefix}landable_traffic"

    # Allow referer path to be null, as we don't always capture a path.
    execute "ALTER TABLE #{schema_name}.referers ALTER COLUMN path_id DROP NOT NULL;"
  end
end
