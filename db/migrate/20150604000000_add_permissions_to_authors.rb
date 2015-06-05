class AddPermissionsToAuthors < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.authors", :read_access, :boolean, null: :false, default: :false
    add_column "#{Landable.configuration.database_schema_prefix}landable.authors", :edit_access, :boolean, null: :false, default: :false
    add_column "#{Landable.configuration.database_schema_prefix}landable.authors", :publish_access, :boolean, null: :false, default: :false
  end
end
