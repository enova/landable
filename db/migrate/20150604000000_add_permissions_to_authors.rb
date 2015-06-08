class AddPermissionsToAuthors < ActiveRecord::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.authors", :groups, :string, null: :false, default: ""
  end
end
