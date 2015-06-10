class AddGroupsToAccessTokens < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.access_tokens", :permissions, :string, array: true
  end
end
