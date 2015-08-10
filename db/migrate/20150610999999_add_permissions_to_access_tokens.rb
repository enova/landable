class AddPermissionsToAccessTokens < ActiveRecord::Migration
  def change
    enable_extension 'hstore' unless extension_enabled?('hstore')
    add_column "#{Landable.configuration.database_schema_prefix}landable.access_tokens", :permissions, :hstore
  end
end
