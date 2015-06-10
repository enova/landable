class AddGroupsToAccessTokens < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.access_tokens", :groups, :string, array: true
  end
end
