class LandablePagesAddLockVersion < Landable::Migration
  def change
    add_column "#{Landable.configuration.database_schema_prefix}landable.pages", :lock_version, :integer, default: 0, null: false
  end
end
